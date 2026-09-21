#!/bin/bash
###############################################################################
# Bioinformatics Automation Script
#
# Integrates:
#   1. Database Retrieval   (NCBI / Ensembl / UniProt)
#   2. BLAST                (BLASTn / BLASTp / BLASTX pairwise alignment)
#   3. Multiple Sequence Alignment + Phylogenetic Tree (MUSCLE / MAFFT / PhyML)
#   4. Primer Design        (Primer3, from FASTA / accession / FASTQ)
#
# Authors: Ali Ali, Esraa Ibrahim, Mai Hussien, Rofaida Abdullah
#
# Required tools (must be installed and on PATH):
#   ncbi-blast+ (blastn, blastp, blastx, makeblastdb), edirect (efetch),
#   mafft, muscle, seqmagick, phyml, seaview, figtree,
#   primer3 (primer3_core), curl, wget, jq, bash
#
# Usage:
#   chmod +x bioinformatics_automation.sh
#   ./bioinformatics_automation.sh
###############################################################################

# =============================================================================
# 1. DATABASE RETRIEVAL
# =============================================================================

function retrieve_from_ncbi() {
    local database_type="$1"
    local search_criteria="$2"

    case $database_type in
        "gene")
            curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=gene&id=$search_criteria&rettype=fasta&retmode=text"
            ;;
        "nucleotide")
            curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nucleotide&id=$search_criteria&rettype=fasta&retmode=text"
            ;;
        "protein")
            curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=protein&id=$search_criteria&rettype=fasta&retmode=text"
            ;;
        *)
            echo "Unsupported NCBI database type: $database_type"
            ;;
    esac
}

function retrieve_from_ensembl() {
    local search_criteria="$1"
    curl -s "https://rest.ensembl.org/lookup/id/$search_criteria?content-type=text/x-fasta"
}

function retrieve_from_uniprot() {
    local search_criteria="$1"
    curl -s "https://www.uniprot.org/uniprotkb/$search_criteria.fasta"
}

function retrieve_data() {
    local database="$1"
    local search_criteria="$2"

    case $database in
        "NCBI")
            echo "Retrieving data from NCBI..."
            retrieve_from_ncbi "$selected_ncbi_db" "$search_criteria"
            ;;
        "Ensembl")
            echo "Retrieving data from Ensembl..."
            retrieve_from_ensembl "$search_criteria"
            ;;
        "UniProt")
            echo "Retrieving data from UniProt..."
            retrieve_from_uniprot "$search_criteria"
            ;;
        *)
            echo "Unsupported database. Please choose NCBI, Ensembl, or UniProt."
            ;;
    esac
}

function run_database_retrieval() {
    while true; do
        echo "---------------------DATABASE RETRIEVAL---------------------"
        echo "1. NCBI"
        echo "2. Ensembl"
        echo "3. UniProt"
        echo "4. Return to Main Menu."
        echo "5. Exit."
        read -p "Enter your choice: " database_number

        case $database_number in
            1)
                database="NCBI"
                echo "Select the NCBI database type:"
                echo "1. gene"
                echo "2. nucleotide"
                echo "3. protein"
                read -p "Enter your choice: " ncbi_choice
                case $ncbi_choice in
                    1) selected_ncbi_db="gene" ;;
                    2) selected_ncbi_db="nucleotide" ;;
                    3) selected_ncbi_db="protein" ;;
                    *)
                        echo "Invalid choice. Please enter a valid option."
                        continue
                        ;;
                esac
                ;;
            2)
                database="Ensembl"
                ;;
            3)
                database="UniProt"
                ;;
            4)
                break
                ;;
            5)
                echo "Exiting..."
                sleep 2
                exit 0
                ;;
            *)
                echo "Invalid database number. Please enter a valid choice."
                continue
                ;;
        esac

        read -p "Enter the search criteria (accession/ID): " search_criteria
        result=$(retrieve_data "$database" "$search_criteria")
        echo "$result"

        read -p "Save this result to a FASTA file? (y/n): " save_choice
        if [[ "$save_choice" == "y" || "$save_choice" == "Y" ]]; then
            read -p "Enter output filename (e.g. retrieved.fasta): " out_name
            echo "$result" > "$out_name"
            echo "Saved to $out_name"
        fi
    done
}

# =============================================================================
# 2. BLAST: PAIRWISE SEQUENCE ALIGNMENT
# =============================================================================

function get_query_input() {
    local db_program="$1"   # nuccore or protein, used for accession efetch
    echo "Choose the type of your input:"
    echo "1. FASTA file"
    echo "2. Accession number"
    echo "3. FASTQ file"
    read -p "Enter your choice: " input_type

    case $input_type in
        1)
            read -p "Enter the path to your FASTA file: " fasta_file
            if [ ! -f "$fasta_file" ]; then
                echo "File not found: $fasta_file"
                query=""
                return 1
            fi
            query="$fasta_file"
            ;;
        2)
            read -p "Enter the accession number: " accession_number
            efetch -db "$db_program" -id "$accession_number" -format fasta > query_seq.fasta
            query="query_seq.fasta"
            ;;
        3)
            read -p "Enter the path to your FASTQ file: " fastq
            if [ ! -f "$fastq" ]; then
                echo "File not found: $fastq"
                query=""
                return 1
            fi
            sed -n '1~4s/^@/>/p;2~4p' "$fastq" > fasta_q.fasta
            query="fasta_q.fasta"
            ;;
        *)
            echo "Invalid input type."
            query=""
            return 1
            ;;
    esac
    return 0
}

function get_blast_db() {
    local dbtype="$1"   # nucl or prot
    echo "Choose the type of your database:"
    echo "1. Local FASTA file"
    echo "2. NCBI RefSeq database (provide a URL)"
    read -p "Enter your choice: " db_type

    case $db_type in
        1)
            read -p "Enter the path to your local BLAST database FASTA: " local_db
            if [ ! -f "$local_db" ]; then
                echo "Local database file not found in the specified path."
                db_name=""
                return 1
            fi
            db_name="$local_db"
            ;;
        2)
            read -p "Enter the URL to download the reference genome from RefSeq: " refseq_url
            wget -q "$refseq_url"
            gunzip -f "$(basename "$refseq_url")"
            db_name="$(basename "$refseq_url" .gz)"
            ;;
        *)
            echo "Invalid database type."
            db_name=""
            return 1
            ;;
    esac

    makeblastdb -in "$db_name" -dbtype "$dbtype"
    return 0
}

function run_blast() {
    while true; do
        echo "---------------------BLAST---------------------"
        echo "Choose the type of BLAST you want to do:"
        echo "1. BLASTn"
        echo "2. BLASTp"
        echo "3. BLASTX"
        echo "4. Return To Main Menu."
        echo "5. Exit"
        read -p "Enter your choice: " blast_type

        case $blast_type in
            1)
                get_query_input "nuccore" || continue
                get_blast_db "nucl" || continue
                blastn -query "$query" -db "$db_name" -out blast_output.txt
                echo "Results saved to blast_output.txt"
                ;;
            2)
                get_query_input "protein" || continue
                get_blast_db "prot" || continue
                blastp -query "$query" -db "$db_name" -out blast_output.txt
                echo "Results saved to blast_output.txt"
                ;;
            3)
                get_query_input "nuccore" || continue
                get_blast_db "prot" || continue
                blastx -query "$query" -db "$db_name" -out blast_output.txt
                echo "Results saved to blast_output.txt"
                ;;
            4)
                break
                ;;
            5)
                echo "Exiting..."
                sleep 2
                exit 0
                ;;
            *)
                echo "Invalid input type."
                ;;
        esac
    done
}

# =============================================================================
# 3. MULTIPLE SEQUENCE ALIGNMENT + PHYLOGENETIC TREE
# =============================================================================

function collect_msa_input() {
    tmp_file="all_sequences.fasta"
    rm -f "$tmp_file"
    while true; do
        echo "Please Choose Your Input:"
        echo "1. Nucleotide Sequences (Accession Numbers)."
        echo "2. Protein Sequences (Accession Numbers)."
        echo "3. FASTA File with Nucleotide or Protein Sequences."
        echo "4. Return To M.S.A Tools."
        echo "5. EXIT!"
        read -p "Enter your choice: " msa_input

        case $msa_input in
            1)
                read -p "Enter the nucleotide accession numbers (separated by spaces): " -a accessions
                for accession in "${accessions[@]}"; do
                    efetch -db nuccore -id "$accession" -format fasta >> "$tmp_file"
                done
                ;;
            2)
                read -p "Enter the protein accession numbers (separated by spaces): " -a accessions
                for accession in "${accessions[@]}"; do
                    efetch -db protein -id "$accession" -format fasta >> "$tmp_file"
                done
                ;;
            3)
                read -p "Enter the path to your FASTA file: " fafile
                if [ -f "$fafile" ]; then
                    cat "$fafile" >> "$tmp_file"
                else
                    echo "File '$fafile' not found."
                    continue
                fi
                ;;
            4)
                return 1
                ;;
            5)
                echo "Exiting..."
                sleep 2
                exit 0
                ;;
            *)
                echo "Invalid input type."
                continue
                ;;
        esac
        return 0
    done
}

function build_tree_from_msa() {
    # Convert CLUSTAL -> FASTA -> PHYLIP, then run PhyML
    seqmagick convert --input-format clustal --output-format fasta MSA_output.clustal MSA_output.fasta
    seqmagick convert --input-format fasta --output-format phylip MSA_output.fasta MSA_output.phy
    phyml -i MSA_output.phy -d nt -m HKY85 -c 4 -a e -b -1
    echo "Sequences aligned and tree file was generated."
}

function run_msa() {
    while true; do
        echo "---------------------MSA & PHYLOGENETIC TREE---------------------"
        echo "Please Choose the M.S.A tool:"
        echo "1. MUSCLE."
        echo "2. MAFFT."
        echo "3. Visualize the Result. (After Performing M.S.A)"
        echo "4. Return to Main Menu."
        echo "5. EXIT!."
        read -p "Enter your choice: " msa_tool

        case $msa_tool in
            1)
                collect_msa_input || continue
                muscle -in "$tmp_file" -out MSA_output.clustal -clwstrict
                build_tree_from_msa
                rm -f "$tmp_file"
                ;;
            2)
                collect_msa_input || continue
                mafft --auto "$tmp_file" > MSA_output.clustal
                build_tree_from_msa
                rm -f "$tmp_file"
                ;;
            3)
                echo "1. Visualize M.S.A With SeaView."
                echo "2. Visualize the Phylogenetic tree With FigTree."
                echo "3. Return to previous menu."
                read -p "Enter your choice: " vis_num
                case $vis_num in
                    1)
                        echo "Starting SeaView..."
                        sleep 2
                        seaview MSA_output.clustal
                        ;;
                    2)
                        echo "Starting FigTree..."
                        figtree -graphic PNG MSA_output.phy_phyml_tree.txt > tree.png
                        echo "Tree image saved to tree.png"
                        ;;
                    3)
                        continue
                        ;;
                    *)
                        echo "Invalid option."
                        ;;
                esac
                ;;
            4)
                break
                ;;
            5)
                echo "Exiting..."
                sleep 2
                exit 0
                ;;
            *)
                echo "Invalid option."
                ;;
        esac
    done
}

# =============================================================================
# 4. PRIMER DESIGN
# =============================================================================

function write_primer3_input() {
    local seq_file="$1"
    primer_input="primer_input.txt"
    {
        echo "SEQUENCE_ID=$(grep "^>" "$seq_file" | sed 's/^>//')"
        echo "SEQUENCE_TEMPLATE=$(grep -v "^>" "$seq_file" | tr -d '\n')"
        echo "PRIMER_TASK=pick_detection_primers"
        echo "PRIMER_PICK_LEFT_PRIMER=1"
        echo "PRIMER_PICK_INTERNAL_OLIGO=1"
        echo "PRIMER_PICK_RIGHT_PRIMER=1"
        echo "PRIMER_PRODUCT_SIZE_RANGE=100-300"
        echo "="
    } > "$primer_input"

    primer3_core "$primer_input" > primers.txt
    echo "Primers designed and saved to primers.txt."
}

function run_primer_design() {
    while true; do
        echo "---------------------PRIMER DESIGN---------------------"
        echo "1. Design primers from a FASTA file."
        echo "2. Design primers for a sequence by accession number."
        echo "3. Design primers from a FASTQ file."
        echo "4. Return to the main menu."
        echo "5. Exit."
        read -p "Enter your choice: " file_type

        case $file_type in
            1)
                read -p "Enter the path to the input FASTA file: " input_file
                if [ -f "$input_file" ]; then
                    write_primer3_input "$input_file"
                else
                    echo "File not found. Please enter a valid file path."
                fi
                ;;
            2)
                read -p "Enter the accession number: " accession_p
                if [ -n "$accession_p" ]; then
                    efetch -db nuccore -id "$accession_p" -format fasta > accession_input.fasta
                    write_primer3_input "accession_input.fasta"
                else
                    echo "Invalid input. Please enter a valid accession number."
                fi
                ;;
            3)
                read -p "Enter the path to the input FASTQ file: " input_fastq
                if [ -f "$input_fastq" ]; then
                    sed -n '1~4s/^@/>/p;2~4p' "$input_fastq" > fastq_input.fasta
                    write_primer3_input "fastq_input.fasta"
                else
                    echo "File not found. Please enter a valid file path."
                fi
                ;;
            4)
                break
                ;;
            5)
                echo "Exiting..."
                sleep 2
                exit 0
                ;;
            *)
                echo "Invalid input. Please select a valid option."
                ;;
        esac
    done
}

# =============================================================================
# MAIN MENU
# =============================================================================

function show_help() {
    echo "---------------------HELP---------------------"
    echo "1. Choose the tool you want to use by entering its number."
    echo "2. Follow the prompts to enter the required information for each tool."
    echo "3. Make sure this script is executable: chmod +x bioinformatics_automation.sh"
    echo "4. Required external tools and installation links:"
    echo "        efetch/edirect: https://www.ncbi.nlm.nih.gov/books/NBK179288/"
    echo "        blast+:         https://blast.ncbi.nlm.nih.gov/doc/blast-help/downloadblastdata.html"
    echo "        mafft:          https://mafft.cbrc.jp/alignment/software/source.html"
    echo "        muscle:         https://www.drive5.com/muscle/manual/install.html"
    echo "        phyml:          https://bioweb.pasteur.fr/docs/modules/phyml/3.0.1/phyml_manual_2008.pdf"
    echo "        seaview:        https://howtoinstall.co/package/seaview"
    echo "        seqmagick:      https://launchpad.net/ubuntu/focal/+source/seqmagick"
    echo "        figtree:        http://tree.bio.ed.ac.uk/software/figtree/"
    echo "        primer3:        https://primer3.org/"
    echo "5. All tool parameters use sensible defaults; run 'man <tool_name>' to see all options."
}

while true; do
    echo ""
    echo "---------------------WELCOME TO THE BIOINFORMATICS AUTOMATION TOOL---------------------"
    echo "What can I help you with? (Choose by number)"
    echo ""
    echo "1. DATABASE RETRIEVAL (NCBI / Ensembl / UniProt)."
    echo "2. BLAST: PAIRWISE SEQUENCE ALIGNMENT."
    echo "3. MULTIPLE SEQUENCE ALIGNMENT AND PHYLOGENETIC TREE."
    echo "4. PRIMER DESIGN."
    echo "5. HELP!"
    echo "6. EXIT PROGRAM."
    read -p "Choose the tool: " tool

    case $tool in
        1)
            run_database_retrieval
            ;;
        2)
            run_blast
            ;;
        3)
            run_msa
            ;;
        4)
            run_primer_design
            ;;
        5)
            show_help
            ;;
        6)
            echo "Exiting..."
            sleep 1
            exit 0
            ;;
        *)
            echo "Invalid input. Please enter a valid number."
            ;;
    esac
done
