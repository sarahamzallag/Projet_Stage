# more /home/nevers/Documents/Dev/proteome_quality/ProteomeQuality

#!/usr/bin/env python3
__author__ = "Yannis Nevers"

import os
import sys
import Proteome_Parser as protParse
import re
import argparse
import Taxonomy as taxo
import requests as req
import xml.etree.ElementTree as ET
import time
import psycopg2
import psycopg2.extras
import json


# This function write the report of a given proteome in term of "ISoforms":
# It will count the number of genes for which No_Gn exists
# It will report the cases of GeneName redundancy
# Report the numbeer of Trembl fragments
# PRoteome Size will be idneicated as reference
def write_proteome_reports(
    proteome_file,
    proteomelist=None,
    universal_prot=None,
    BUSCO_info=None,
    OMARK_info=None,
    header=False,
    taxonomy=True
):
    csv_report = sys.stdout
    report_to_write = []

    categories = [
        "File name",
        "Taxid",
        "Organism",
        "Proteome Size",
        "Swissprot",
        "Trembl",
        "No gene names",
        "Identical Genenames",
        "Fragments (Annotated)",
        "% Fragments (Annotated)",
        "First Quartile",
        "Small proteins (<100)",
        "No start codons proteins",
    ]

    if proteomelist:
        orga_qual = fetch_genome_quality(proteomelist)
        categories.append("NContig")
        categories.append("N50")

    if universal_prot:
        for threshold, protlist in universal_prot.items():
            categories.append("Proportion universal_" + threshold)

    if BUSCO_info:
        categories.append("Total (BUSCO)")
        categories.append("Fragment (BUSCO)")
        categories.append("Missing (BUSCO)")
    if OMARK_info:
        categories.append("Conserved HOGs (OMArk)")
        categories.append("% Single (OMArk)")
        categories.append("% Duplicated (OMArk)")
        categories.append("% Missing (OMArk)")
        categories.append("Consistent total (OMArk)")
        categories.append("Consistent partial (OMArk)")
        categories.append("Consistent fragmented (OMArk)")
        categories.append("Inconsistent total (OMArk)")
        categories.append("Contaminants total (OMArk)")
        categories.append("Unknown total (OMArk)")
        categories.append("Used clade (OMArk)")
        categories.append("Detected clade (OMArk)")
    if taxonomy:
        categories.append("Taxonomy")

    if header:
        report_to_write.append("\t".join(categories))

    complete_filepath = proteome_file

    # Check the files corresponds to Proteome files
    assert os.path.isfile(complete_filepath), (
        f"Cannot read proteome file {complete_filepath}"
    )
    current_proteome = protParse.ProteomeParser(complete_filepath)

    no_gn, duplicate, fragments, swissprot, trembl = redundancy_analysis(
        current_proteome
    )
    proteome_stats = current_proteome.protein_length_stats(100)
    non_starts_prots = current_proteome.get_nonstart_proteins()
    num_identical = 0
    for identical_gn in duplicate:
        num_identical += len(duplicate[identical_gn])

    organism_line = []
    orga_name = current_proteome.organism
    if taxonomy:
        taxid, species_name = taxo.get_proteome_taxonomy(complete_filepath)
        assert taxid != None, f"Couldn't find taxid of proteome {proteome_file}"
    else:
        taxid = None
        species_name = None
    # File name
    organism_line.append(os.path.basename(complete_filepath))
    # Taxid
    organism_line.append(taxid)
    # Organism name
    organism_line.append(species_name)
    # Proteome Size
    prot_size = len(current_proteome.proteins)
    organism_line.append(str(prot_size))
    # Swissprot
    organism_line.append(str(len(swissprot)))
    # Trembl
    organism_line.append(str(len(trembl)))
    # No gene names
    organism_line.append(str(len(no_gn)))
    # Identical GeneNames
    organism_line.append(str(num_identical))
    # Fragments (Annotated)
    organism_line.append(str(len(fragments)))
    # % Fragments (Annotated)
    percent_fragments = len(fragments) / prot_size
    organism_line.append(str(percent_fragments))
    # First_Quartile
    first_quart = proteome_stats[3]
    organism_line.append(str(first_quart))
    # Small Proteins (<100)
    small_proteins = proteome_stats[7]
    organism_line.append(str(len(small_proteins) * 100 / prot_size))
    # No Start Codons
    organism_line.append(str(len(non_starts_prots) * 100 / prot_size))

    if proteomelist:
        proteomeid = file.split("_")[0]
        if proteomeid in orga_qual and orga_qual[proteomeid]:
            data = orga_qual[proteomeid]
            organism_line.append(data.get("NContig"))
            organism_line.append(data.get("N50"))
        else:
            organism_line.append("Not found")
            organism_line.append("Not found")

    if universal_prot:
        for threshold, protlist in universal_prot.items():
            conserv = evaluate_conservation(taxid, protlist)
            organism_line.append(str(conserv))

    if BUSCO_info:
        busco_qual = BUSCO_info
        organism_line.append(busco_qual["total"])
        organism_line.append(busco_qual["fragment"])
        organism_line.append(busco_qual["missing"])

    if OMARK_info:
        om = OMARK_info
        organism_line.append(om["hogs_total"])
        organism_line.append(om["single"])
        organism_line.append(om["duplicated"])
        organism_line.append(om["missing"])
        organism_line.append(om["consistent_total_percent"])
        organism_line.append(om["consistent_partial_percent"])
        organism_line.append(om["consistent_fragmented_percent"])
        organism_line.append(om["inconsistent_total_percent"])
        organism_line.append(om["contaminants_total_percent"])
        organism_line.append(om["unknown_total_percent"])
        organism_line.append(om["used_clade"])
        organism_line.append(om["detected_clade"])
    if taxonomy:
        # Taxonomy
        taxonomy = taxo.get_lineage(taxid)
        organism_line.append(taxonomy)

    report_to_write.append("\t".join([str(x) for x in organism_line]))

    for l in report_to_write:
        csv_report.write("%s\n" % l)


# Take a Proteome object as issued from ProteomeParser and check isofroems datas (No gene name, identifcal gene
# naames, fragment)
def redundancy_analysis(Proteome):
    # List containing all protein object with no genename, all informations will be kept for further analysis
    no_genenames = list()
    # List of protein contening Fragments
    fragment_prot = list()
    # List of Unique Genename, allowing to count the difference. This method is not quite clean and need refinement
    gn_unique = list()
    # List of GeneName that are duplicated or more
    duplicated_gn = dict()
    # List of Swissprot protein
    sp_prot = list()
    # List of Trembl protein
    tr_prot = list()
    for protein in Proteome.proteins:
        desc = protein.description
        gname = protein.genename
        database = protein.database
        if database == "sp":
            sp_prot.append(protein)
        elif database == "tr":
            tr_prot.append(protein)
        if not gname:
            no_genenames.append(protein)
            continue

        if gname in gn_unique:
            if gname not in duplicated_gn:
                duplicated_gn[gname] = 0
            else:
                duplicated_gn[gname] += 1
        else:
            gn_unique.append(gname)
        if re.search("fragments?", desc, re.I):
            fragment_prot.append(protein)

    # Now get all proteins with duplicated genenames
    duplicate_entry = dict()
    for duplicate in duplicated_gn:
        duplicate_entry[duplicate] = Proteome.getAllProtWithGn(duplicate)
    return no_genenames, duplicate_entry, fragment_prot, sp_prot, tr_prot


def write_protlength_reports(proteome_directory, outfile, log_files_dir=None):
    files = os.listdir(proteome_directory)
    csv_report = open(outfile, "w")
    report_to_write = []
    fline = "Organism, Proteome Size, Length_Mean, Length_Std, Min, First_Quartile, Median, Third_Quartile, Max"

    report_to_write.append(fline)

    for file in files:
        complete_filepath = os.path.join(proteome_directory, file)
        # Check the files corresponds to Proteome files
        if os.path.isfile(complete_filepath):
            current_proteome = protParse.ProteomeParser(complete_filepath)
            organism_line = []
            mean, std, min, fquart, median, tquart, max, nbsmall = (
                current_proteome.protein_length_stats()
            )

            # Organism
            organism_line.append(current_proteome.organism)
            # Proteome size
            organism_line.append(str(len(current_proteome.proteins)))
            # Mean
            organism_line.append(str(mean))
            # Standard deviation
            organism_line.append(str(std))
            # Minimum
            organism_line.append(str(min))
            # First quartile
            organism_line.append(str(fquart))
            # Median
            organism_line.append(str(median))
            # Third quartile
            organism_line.append(str(tquart))
            # Maximum
            organism_line.append(str(max))
            # Number of small protein
            organism_line.append(str(len(nbsmall)))

            report_to_write.append("\t".join(organism_line))

            if log_files_dir:
                pass
    for l in report_to_write:
        csv_report.write("%s\n" % l)


def write_aa_prot_reports(proteome_directory, outfile, log_files_dir=None):
    files = os.listdir(proteome_directory)
    csv_report = open(outfile, "w")
    report_to_write = []
    first_line = [
        "Organism",
        "P",
        "G",
        "A",
        "V",
        "L",
        "I",
        "S",
        "T",
        "M",
        "C",
        "D",
        "E",
        "N",
        "Q",
        "K",
        "R",
        "H",
        "F",
        "Y",
        "W",
        "U",
        "B",
        "X",
    ]
    report_to_write.append(", ".join(first_line))
    for file in files:
        complete_filepath = os.path.join(proteome_directory, file)
        print(file)
        if os.path.isfile(complete_filepath):
            current_proteome = protParse.ProteomeParser(complete_filepath)
            aa_prop = current_proteome.get_aa_proportions()
            proteom_line = []
            for elem in first_line:
                if elem == "Organism":
                    proteom_line.append(current_proteome.organism)
                elif elem in aa_prop:
                    proteom_line.append(str(aa_prop[elem]))
                else:
                    proteom_line.append("0")
            report_to_write.append(",".join(proteom_line))

    for l in report_to_write:
        csv_report.write("%s\n" % l)


def fetch_genome_quality(proteomefile):
    quality_dic = dict()

    with open(proteomefile) as prot:
        first = True
        for line in prot.readlines():
            if first:
                first = False
                continue

            line = line.strip("\n")
            categories = line.split("\t")
            # print(categories[4],categories[5])
            orga_quality = dict()

            if categories[5] != "":
                print(categories[0])
                # print("www.ebi.ac.uk/ena/data/view/{}&display=xml".format(categories[5]))
                r = req.get(
                    "http://www.ebi.ac.uk/ena/data/view/{}&display=xml".format(
                        categories[5]
                    )
                )
                xmltext = r.text
                root = ET.fromstring(xmltext)
                for elem in root.iter("ASSEMBLY_ATTRIBUTE"):
                    tag = elem.find("TAG")
                    value = elem.find("VALUE")
                    if tag.text == "n50":
                        print("N50: " + value.text)
                        orga_quality["N50"] = value.text
                    elif tag.text == "count-contig":
                        print("Ncontig: " + value.text)
                        orga_quality["NContig"] = value.text
            if orga_quality:
                quality_dic[categories[0]] = orga_quality
            else:
                quality_dic[categories[0]] = None
            time.sleep(0.5)
            # for child in root:
    return quality_dic


def evaluate_conservation(taxid, protlist):
    total = len(protlist)

    protstr = "'" + "','".join(protlist) + "'"
    query = """SELECT COUNT(DISTINCT access) FROM (
                SELECT othtar.* FROM otherid AS oth
                JOIN onetoone oto ON oto.pk_sequencea=oth.pk_sequence
                JOIN otherid AS othtar ON othtar.pk_sequence=oto.pk_sequenceb
                JOIN ln_organism_bank AS lnob ON lnob.pk_organism=oto.pk_organisma
                WHERE lnob.taxid = {0}
                AND othtar.access IN ({1})
                UNION
                SELECT othtar.* FROM otherid AS oth
                JOIN onetoone oto ON oto.pk_sequenceb=oth.pk_sequence
                JOIN otherid AS othtar ON othtar.pk_sequence=oto.pk_sequencea
                JOIN ln_organism_bank AS lnob ON lnob.pk_organism=oto.pk_organismb
                WHERE lnob.taxid = {0}
                AND othtar.access IN ({1})
                /*OTM*/
                UNION
                SELECT othtar.* FROM otherid AS oth
                JOIN onetomany AS otm ON otm.pk_sequencea=oth.pk_sequence
                JOIN ln_inparalog_sequence AS lnis ON otm.pk_inparalogb=lnis.pk_inparalog
                JOIN otherid AS othtar ON lnis.pk_sequence=othtar.pk_sequence
                JOIN ln_organism_bank AS lnob ON lnob.pk_organism=otm.pk_organisma
                WHERE lnob.taxid = {0}
                AND othtar.access IN ({1})
                UNION
                SELECT othtar.* FROM otherid AS oth
                JOIN ln_inparalog_sequence  AS lnis ON oth.pk_sequence=lnis.pk_sequence
                JOIN onetomany otm ON lnis.pk_inparalog=otm.pk_inparalogb
                JOIN otherid AS othtar ON othtar.pk_sequence=otm.pk_sequencea
                JOIN ln_organism_bank AS lnob ON lnob.pk_organism=otm.pk_organismb
                WHERE lnob.taxid = {0}
                AND othtar.access IN ({1})
                /*MTM*/
                UNION
                SELECT othtar.* FROM otherid AS oth
                JOIN ln_inparalog_sequence AS lnis ON oth.pk_sequence=lnis.pk_sequence
                JOIN manytomany AS mtm ON lnis.pk_inparalog=mtm.pk_inparaloga
                JOIN ln_inparalog_sequence AS lnistar ON lnistar.pk_inparalog=mtm.pk_inparalogb
                JOIN otherid AS othtar ON othtar.pk_sequence=lnistar.pk_sequence
                JOIN ln_organism_bank AS lnob ON lnob.pk_organism=mtm.pk_organisma
                WHERE lnob.taxid = {0}
                AND othtar.access IN ({1})
                UNION
                SELECT othtar.* FROM otherid AS oth
                JOIN ln_inparalog_sequence AS lnis ON oth.pk_sequence=lnis.pk_sequence
                JOIN manytomany AS mtm ON lnis.pk_inparalog=mtm.pk_inparalogb
                JOIN ln_inparalog_sequence AS lnistar ON lnistar.pk_inparalog=mtm.pk_inparaloga
                JOIN otherid AS othtar ON othtar.pk_sequence=lnistar.pk_sequence
                JOIN ln_organism_bank AS lnob ON lnob.pk_organism=mtm.pk_organismb
                WHERE lnob.taxid = {0}
                AND othtar.access IN ({1})
            )AS dt ;
                """.format(taxid, protstr)

    conn = psycopg2.connect(
        dbname="OrthoInspector_Archaea_2016",
        user="nevers",
        password="nisNEVER",
        host="biplan",
        port=str(5432),
    )
    cur = conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
    cur.execute(query)
    rows = cur.fetchall()
    numprot = rows[0][0]
    prop = numprot * 100 / total
    return prop


def parse_BUSCO_results(busco_dir):
    file_list = [f for f in os.listdir(busco_dir) if f.endswith(".json")]
    assert len(file_list) == 1, f"Cannot find BUSCO JSON output file in dir {busco_dir}"
    json_path = file_list[0]

    with open(f"{busco_dir}/{file_list[0]}", "r") as f:
        data = json.load(f)
    res = {
        "total": data["results"]["Complete percentage"],
        "fragment": data["results"]["Fragmented percentage"],
        "missing": data["results"]["Missing percentage"],
    }
    return res


def parse_OMARK_file(path):
    # Number of conserved HOGs
    # % Single
    # % Duplicated
    # % Missing
    # Total Consistent, partial and fragmented hits
    # Total inconsistent
    # Total contaminants
    # Total unknown
    # Detected clade
    # Associated query proteins
    res = {}

    f = open(path, "r")
    for line in f.readlines():
        d = re.search("The selected clade was (.+)", line)
        if d:
            res["used_clade"] = d.group(1)
        d = re.search(
            r"^S:([0-9]+),D:([0-9]+)\[U:([0-9]+),E:([0-9]+)\],M:([0-9]+)", line
        )
        if d:
            res["hogs_total"] = str(int(d.group(1)) + int(d.group(2)) + int(d.group(5)))
        d = re.search(
            r"^S:([0-9\.]+)%,D:([0-9\.]+)%\[U:([0-9\.]+)%,E:([0-9\.]+)%\],M:([0-9\.]+)%",
            line,
        )
        if d:
            res["single"] = d.group(1)
            res["duplicated"] = d.group(2)
            res["missing"] = d.group(5)
        d = re.search(
            r"^A:([0-9]+)\[P:([0-9]+),F:([0-9]+)\],I:([0-9]+)\[P:([0-9]+),F:([0-9]+)\],C:([0-9]+)\[P:([0-9]+),F:([0-9]+)\],U:([0-9]+)",
            line,
        )
        if d:
            res["consistent_total"] = d.group(1)
            res["consistent_partial"] = d.group(2)
            res["consistent_fragmented"] = d.group(3)
            res["inconsistent_total"] = d.group(4)
            res["contaminants_total"] = d.group(7)
            res["unknown_total"] = d.group(10)

        d = re.search(
            r"^A:([0-9\.]+)%\[P:([0-9\.]+)%,F:([0-9\.]+)%\],I:([0-9\.]+)%\[P:([0-9\.]+)%,F:([0-9\.]+)%\],C:([0-9\.]+)%\[P:([0-9\.]+)%,F:([0-9\.]+)%\],U:([0-9\.]+)%"
,
            line,
        )
        if d:
            res["consistent_total_percent"] = d.group(1)
            res["consistent_partial_percent"] = d.group(2)
            res["consistent_fragmented_percent"] = d.group(3)
            res["inconsistent_total_percent"] = d.group(4)
            res["contaminants_total_percent"] = d.group(7)
            res["unknown_total_percent"] = d.group(10)

        if re.search("^[^#][^:]", line):
            detected_clade, taxid, associated_proteins, percent_associated_proteins = (
                line.split("\t")
            )
            res["detected_clade"] = detected_clade
        elif re.search("^#Potential contaminants:", line):
            break
    return res


def parse_OMARK_results(omark_dir):
    file_list = [f for f in os.listdir(omark_dir) if f.endswith(".sum")]
    assert len(file_list) == 1, f"Cannot find OMARK .sum output file in dir {omark_dir}"
    return parse_OMARK_file(f"{omark_dir}/{file_list[0]}")


def extract_list(file):
    protlist = list()
    with open(file, "r") as protfile:
        for line in protfile.readlines():
            line = line.strip("\n")
            if line != "":
                protlist.append(line)
    return protlist


def ProteomeArg():
    parser = argparse.ArgumentParser(
        description="Parse proteome and extract statistics about it"
    )
    parser.add_argument("proteome", type=str, help="Proteome FASTA file to process")
    parser.add_argument(
        "-b",
        "--busco",
        type=str,
        default=None,
        help="Optional. Path to the BUSCO output dir",
    )
    parser.add_argument(
        "-k",
        "--omark",
        type=str,
        default=None,
        help="Optional. Path to the OMARK output dir",
    )
    parser.add_argument(
        "-g",
        "--genref",
        type=str,
        default=None,
        help="Path to the Uniprot file giving the "
        "corresponding genome "
        "reference. Such file can be downloaded from the search "
        "page of Uniprot, while selecting the corresponding "
        "column type",
    )

    parser.add_argument(
        "-t",
        "--taxonomy",
        action='store_false',
        default=True,
        help="Use this option to deactivate the taxonomy part of this script." \
        "To use with FASTA file that are not formatised in a standard compatible with UniProt/RefSeq"
    )

    parser.add_argument("-H", "--header", action="store_true", help="Print header")
    args = parser.parse_args()

    return args


if __name__ == "__main__":
    args = ProteomeArg()

    proteome = args.proteome
    busco = args.busco
    omark = args.omark
    genomesRef = args.genref
    header = args.header
    taxonomy = args.taxonomy

    buscodata = parse_BUSCO_results(busco) if busco else None
    omarkdata = parse_OMARK_results(omark) if omark else None
    write_proteome_reports(proteome, genomesRef, None, buscodata, omarkdata, header, taxonomy)
    # write_protlength_reports("/gstock/user/nevers/OrthoInspector_Proteomes/Bacteries/NotaBene",
    #                           "/enadisk/gstock/user/nevers/Redundancy_Report/SummaryLengthes_Bacteries_test1.csv")
    # write_aa_prot_reports("/gstock/user/nevers/OrthoInspector_Proteomes/Eukaryotes/",
    #                           "/enadisk/gstock/user/nevers/Redundancy_Report/Summary_aa_Eukaryotes_test1.csv")