#!/bin/bash

# Define a function to run the BLAST script
function run_blast {
    while true; do
        # Asking user about blast type.
        echo "Choose the type of BLAST you want to do:"
        echo "1. BLASTn"
        echo "2. BLASTp"
        echo "3. BLASTX"
        echo "4. Return To Main Menu."
        echo "5. Exit"
        read -p "Enter your choice: " blast_type

        case $blast_type in
            1)
                # BLASTn
                # Asking user about query input file.
                echo "Choose the type of your input:"
                echo "1. FASTA file"
                echo "2. Accession number"
                echo "3. FASTQ file"
                read -p "Enter your choice: " input_type
                # Handle input types
                if [ "$input_type" == "1" ]; then
                    read -p "Enter the path to your FASTA file: " fasta_file
                    if [ ! -f "$fasta_file" ]; then
                        echo "File not found: $fasta_file"
                        continue
                    fi
                    query="$fasta_file"
                elif [ "$input_type" == "2" ]; then
                    read -p "Enter the accession number: " accession_number
                    efetch -db nuccore -id $accession_number -format fasta > query.fasta
                    query="query.fasta"
                elif [ "$input_type" == "3" ]; then
                    read -p  "Enter the path to your FASTQ file: " fastq
                    sed -n '1~4s/^@/>/p;2~4p' $fastq > fasta_q.fasta
                    query="fasta_q.fasta"
                else
                    echo "Invalid input type."
                    continue
                fi
                # Asking user about database input file.
                echo "Choose the type of your database:"
                echo "1. Local FASTA file"
                echo "2. NCBI RefSeq database (provide a URL)"
                read -p "Enter your choice: " db_type
                # Handle database types
                if [ "$db_type" == "1" ]; then
                    read -p "Enter the path to your local BLAST database: " local_db
                    if [ ! -f "$local_db" ]; then
                        echo "Local database files not found in the specified path."
                        continue
                    fi
                    db_name="$local_db"
                elif [ "$db_type" == "2" ]; then
                    read -p "Enter the URL to download the reference genome from RefSeq: " refseq_url
                    wget -q "$refseq_url"
                    gunzip -f $(basename "$refseq_url")
                    db_name="$(basename "$refseq_url" .gz)"
                else
                    echo "Invalid database type."
                    continue
                fi
                # indexing of database on users pc.
                makeblastdb -in "$db_name" -dbtype nucl
                # run BLASTn command.
                blastn -query "$query" -db "$db_name" -out blast_output.txt
                ;;
            2)
                # BLASTp
                # Asking user about query input file.
                echo "Choose the type of your input:"
                echo "1. FASTA file"
                echo "2. Accession number"
                echo "3. FASTQ file"
                read -p "Enter your choice: " input_type
                # Handle input types
                if [ "$input_type" == "1" ]; then
                    read -p "Enter the path to your FASTA file: " fasta_file
                    if [ ! -f "$fasta_file" ]; then
                        echo "File not found: $fasta_file"
                        continue
                    fi
                    query="$fasta_file"
                elif [ "$input_type" == "2" ]; then
                    read -p "Enter the accession number: " accession_number
                    efetch -db protein -id "$accession_number" -format fasta > query_protein.fasta
                    query="query_protein.fasta"
                elif [ "$input_type" == "3" ]; then
                    read -p  "Enter the path to your FASTQ file: " fastq
                    sed -n '1~4s/^@/>/p;2~4p' $fastq > fasta_q.fasta
                    query="fasta_q.fasta"
                else
                    echo "Invalid input type."
                    continue
                fi
                # Asking user about database input file.
                echo "Choose the type of your database:"
                echo "1. Local FASTA file"
                echo "2. NCBI RefSeq database (provide a URL)"
                read -p "Enter your choice: " db_type
                # Handle database types
                if [ "$db_type" == "1" ]; then
                    read -p "Enter the path to your local BLAST database: " local_db
                    if [ ! -f "$local_db" ]; then
                        echo "Local database files not found in the specified path."
                        continue
                    fi
                    db_name="$local_db"
                elif [ "$db_type" == "2" ]; then
                    read -p "Enter the URL to download the reference genome from RefSeq: " refseq_url
                    wget -q "$refseq_url"
                    gunzip -f $(basename "$refseq_url")
                    db_name="$(basename "$refseq_url" .gz)"
                else
                    echo "Invalid database type."
                    continue
                fi
                # indexing of database on users pc.
                makeblastdb -in "$db_name" -dbtype prot
                # run BLASTp command.
                blastp -query "$query" -db "$db_name" -out blast_output.txt
                ;;
            3)
                # BLASTX
                # Asking user about query input file.
                echo "Choose the type of your input:"
                echo "1. FASTA file"
                echo "2. Accession number"
                echo "3. FASTQ file"
                read -p "Enter your choice: " input_type
                # Handle input types
                if [ "$input_type" == "1" ]; then
                    read -p "Enter the path to your FASTA file: " fasta_file
                    if [ ! -f "$fasta_file" ]; then
                        echo "File not found: $fasta_file"
                        continue
                    fi
                    query="$fasta_file"
                elif [ "$input_type" == "2" ]; then
                    read -p "Enter the accession number: " accession_number
                    efetch -db nuccore -id "$accession_number" -format fasta > query_nucleotide.fasta
                    query="query_nucleotide.fasta"
                elif [ "$input_type" == "3" ]; then
                    read -p  "Enter the path to your FASTQ file: " fastq
                    sed -n '1~4s/^@/>/p;2~4p' $fastq > fasta_q.fasta
                    query="fasta_q.fasta"
                else
                    echo "Invalid input type."
                    continue
                fi
                # Asking user about database input file.
                echo "Choose the type of your database:"
                echo "1. Local file"
                echo "2. NCBI RefSeq database (provide a URL)"
                read -p "Enter your choice: " db_type
                # Handle database types
                if [ "$db_type" == "1" ]; then
                    read -p "Enter the path to your local BLAST database: " local_db
                    if [ ! -f "$local_db" ]; then
                        echo "Local database files not found in the specified path."
                        continue
                    fi
                    db_name="$local_db"
                elif [ "$db_type" == "2" ]; then
                    read -p "Enter the URL to download the reference genome from RefSeq: " refseq_url
                    wget -q "$refseq_url"
                    gunzip -f $(basename "$refseq_url")
                    db_name="$(basename "$refseq_url" .gz)"
                else
                    echo "Invalid database type."
                    continue
                fi
                # indexing of database on users pc.
                makeblastdb -in "$db_name" -dbtype prot
                # run BLASTp command.
                blastx -query "$query" -db "$db_name" -out blast_output.txt
                ;;
            4)
                # return to main menu
                break
                ;;
            5)
                # Exiting the program.
                echo "Exiting..."
                sleep 2
                break
                ;;
            *)
                # if user entering invalid option.
                echo "Invalid input type."
                ;;
        esac
    done
}


# Define a function to run the MSA script
function run_msa {
    while true; do
        # Asking user for M.S.A tools.
        echo "Please Choose the M.S.A tool: "
        echo "1. MUSCLE."
        echo "2. MAFFT."
        echo "3. Visualize the Result.( After Performing M.S.A )"
        echo "4. Return to Main Menu."
        echo "5. EXIT!."
        read -p "Enter your choice: " msa_tool

        case $msa_tool in
            1)
                # Starting MUSCLE TOOL.
                tmp_file="all_sequences.fasta"
                while true; do
                    # Asking user about input file.
                    echo "Please Choose Your Input File:"
                    echo "1. Nucleotide Sequences (Accession Numbers)."
                    echo "2. Protein Sequences (Accession Numbers)."
                    echo "3. FASTA File with Nucleotide or Protein Sequences."
                    echo "4. Return To M.S.A Tools."
                    echo "5. EXIT!"
                    read -p "Enter your choice: " msa_input

                    case $msa_input in
                        1)
                            # efetching nucleotide sequence files by accession numbers.
                            read -p "Enter the nucleotide accession numbers (separated by spaces): " -a accessions
                            for accession in "${accessions[@]}"; do
                                efetch -db nuccore -id "$accession" -format fasta >> "$tmp_file"
                            done
                            ;;
                        2)
                            # efetchig amino acid sequence files by accession numbers.
                            read -p "Enter the protein accession numbers (separated by spaces): " -a accessions
                            for accession in "${accessions[@]}"; do
                                efetch -db protein -id "$accession" -format fasta >> "$tmp_file"
                            done
                            ;;
                        3)
                            # if user have nucleotide or amino acid sequences in FASTA file.
                            read -p "Enter the path to your FASTA file: " fafile
                            if [ -f "$fafile" ]; then
                                cat "$fafile" >> "$tmp_file"
                            else
                                echo "File '$fafile' not found."
                                continue
                            fi
                            ;;
                        4)
                            #break case statement to return to previous menu.
                            break
                            ;;
                        5)
                            # Exiting the program
                            echo "Exiting..."
                            sleep 2
                            exit 0
                            ;;
                        *)
                            # if the user entering invalid input
                            echo "Invalid input type."
                            continue
                            ;;
                    esac

                    # Align the sequences.
                    muscle -in "$tmp_file" -out MSA_output.clustal -clwstrict
                    # Convert CLUSTAL format to FASTA format.
                    seqmagick convert --input-format clustal --output-format fasta MSA_output.clustal MSA_output.fasta

                    # Convert FASTA format to PHYLIP format.
                    seqmagick convert --input-format fasta --output-format phylip MSA_output.fasta MSA_output.phy

                    # Run PhyML to build the phylogenetic tree.
                    phyml -i MSA_output.phy -d nt -m HKY85 -c 4 -a e -b -1
                    echo "Sequences aligned and tree file was generated."
                    rm "$tmp_file"  # Remove the temporary file
                    break
                done
                ;;
            2)
                # Starting MAFFT tool.
                tmp_file="all_sequences.fasta"
                while true; do
                    # Asking user about input file.
                    echo "Please Choose Your Input:"
                    echo "1. Nucleotide Sequences (Accession Numbers)."
                    echo "2. Protein Sequences (Accession Numbers)."
                    echo "3. FASTA File with Nucleotide or Protein Sequences."
                    echo "4. Return To M.S.A Tools."
                    echo "5. EXIT!"
                    read -p "Enter your choice: " msa_input

                    case $msa_input in
                        1)
                            # efetching nucleotide sequence files by accession numbers.
                            read -p "Enter the nucleotide accession numbers (separated by spaces): " -a accessions
                            for accession in "${accessions[@]}"; do
                                efetch -db nuccore -id "$accession" -format fasta >> "$tmp_file"
                            done
                            ;;
                        2)
                            # efetchig amino acid sequence files by accession numbers.
                            read -p "Enter the protein accession numbers (separated by spaces): " -a accessions
                            for accession in "${accessions[@]}"; do
                                efetch -db protein -id "$accession" -format fasta >> "$tmp_file"
                            done
                            ;;
                        3)
                            # if user have nucleotide or amino acid sequences in FASTA file.
                            read -p "Enter the path to your FASTA file: " fafile
                            if [ -f "$fafile" ]; then
                                cat "$fafile" >> "$tmp_file"
                            else
                                echo "File '$fafile' not found."
                                continue
                            fi
                            ;;
                        4)
                            #break case statement to return to previous menu.
                            break
                            ;;
                        5)
                            # Exiting the program.
                            echo "Exiting..."
                            sleep 2
                            exit 0
                            ;;
                        *)
                            # if the user entering invalid input.
                            echo "Invalid input type."
                            continue
                            ;;
                    esac

                    # Align the sequences using MAFFT.
                    mafft --auto "$tmp_file" > MSA_output.clustal
                    # Convert CLUSTAL format to FASTA format.
                    seqmagick convert --input-format clustal --output-format fasta MSA_output.clustal MSA_output.fasta

                    # Convert FASTA format to PHYLIP format.
                    seqmagick convert --input-format fasta --output-format phylip MSA_output.fasta MSA_output.phy

                    # Run PhyML to build the phylogenetic tree.
                    phyml -i MSA_output.phy -d nt -m HKY85 -c 4 -a e -b -1
                    echo "Sequences aligned and tree file was generated."
                    rm "$tmp_file"  # Remove the temporary file.
                    break
                done
                ;;
            3)
                # Asking user about visualization tool.
                echo "1. Visualize M.S.A With SeaView."
                echo "2. Visualize the Phylogenetic tree With FigTree."
                echo "3. return to previous menue."
                read -p "Enter your choice: " vis_num
                while true; do
                        case $vis_num in
                            1)
                                # Visualize M.S.A result file by seaview tool.
                                echo "Starting SeaView..."
                                sleep 2
                                seaview MSA_output.clustal
                                exit 0
                                ;;
                            2)
                                # Visualize M.S.A result file as a tree by figtree tool.
                                echo "Starting FigTree..."
                                # Visualize the tree using FigTree.
                                figtree -graphic PNG MSA_output.phy_phyml_tree.txt > tree.png
                                exit 0
                                ;;
                            3)
                                #break case statement to return to previous menu.
                                break
                                ;;
                            *)
                                # if the user entering invalid option.
                                echo "Invalid option." 
                                ;;
                        esac
                done
                ;;
            4)
                # break to return to main menue
                break
                ;;
            5)
                # Exiting the program
                echo "Exiting..."
                sleep 2
                exit 0
                ;;
            *)
                # if the user entering invalid option.
                echo "Invalid option."
                ;;
        esac
    done
}

# Define a function to run the PRIMER DESIGN script
function run_primer_design {
    while true; do
        # Asking user about input file.
        echo "1. Design primers from a FASTA file."
        echo "2. Design primers for a sequence by accession number."
        echo "3. Design primers from a FASTQ file."
        echo "4. Return to the main menu."
        echo "5. Exit."
        read -p "Enter your choice: " file_type

        case $file_type in
            1)
                # if the user have fasta file includes sequence.
                echo "Please enter the path to the input FASTA file:"
                read -p "file path: " input_file
                if [ -f "$input_file" ]; then
                    # converting FASTA file to primer3 input
                    touch primer_input.txt
                    chmod +x primer_input.txt
                    echo "SEQUENCE_ID=$(grep "^>" "$input_file" | sed 's/^>//')" > primer_input.txt
                    echo "SEQUENCE_TEMPLATE=$(grep -v "^>" "$input_file" | tr -d '\n')" >> primer_input.txt
                    echo "PRIMER_TASK=pick_detection_primers" >> primer_input.txt
                    echo "PRIMER_PICK_LEFT_PRIMER=1" >> primer_input.txt
                    echo "PRIMER_PICK_INTERNAL_OLIGO=1" >> primer_input.txt
                    echo "PRIMER_PICK_RIGHT_PRIMER=1" >> primer_input.txt
                    echo "PRIMER_PRODUCT_SIZE_RANGE=100-300" >> primer_input.txt
                    echo "=" >> primer_input.txt
                    # Perform the primer design command
                    primer3_core primer_input.txt > primers.txt
                    echo "Primers designed and saved to primers.txt."
                else
                    echo "File not found. Please enter a valid file path."
                fi
                ;;
            2)
                # if the user wan to efetching sequence by accession number.
                echo "Enter the accession number: "
                read -p "accession: " accession_p
                if [ -n "$accession_p" ]; then
                    efetch -db nuccore -id $accession_p -format fasta > input_file
                    
                    # converting FASTA file to primer3 input
                    touch primer_input.txt
                    chmod +x primer_input.txt
                    echo "SEQUENCE_ID=$(grep "^>" "$input_file" | sed 's/^>//')" > primer_input.txt
                    echo "SEQUENCE_TEMPLATE=$(grep -v "^>" "$input_file" | tr -d '\n')" >> primer_input.txt
                    echo "PRIMER_TASK=pick_detection_primers" >> primer_input.txt
                    echo "PRIMER_PICK_LEFT_PRIMER=1" >> primer_input.txt
                    echo "PRIMER_PICK_INTERNAL_OLIGO=1" >> primer_input.txt
                    echo "PRIMER_PICK_RIGHT_PRIMER=1" >> primer_input.txt
                    echo "PRIMER_PRODUCT_SIZE_RANGE=100-300" >> primer_input.txt
                    echo "=" >> primer_input.txt
                    # Perform the primer design command
                    primer3_core primer_input.txt > primers.txt
                    echo "Primers designed and saved to primers.txt."
                else
                    echo "Invalid input. Please enter a valid accession number."
                fi
                ;;
            3)
                # convert FASTQ to FASTA
                echo "Please enter the path to the input FASTQ file:"
                read -p "Enter your FASTQ file path: " input_fastq
                if [ -f "$input_fastq" ]; then
                    # converting FASTQ file to FASTA
                    sed -n '1~4s/^@/>/p;2~4p' $input_fastq > input_file
                    # converting FASTA file to primer3 input
                    touch primer_input.txt
                    chmod +x primer_input.txt
                    echo "SEQUENCE_ID=$(grep "^>" "$input_file" | sed 's/^>//')" > primer_input.txt
                    echo "SEQUENCE_TEMPLATE=$(grep -v "^>" "$input_file" | tr -d '\n')" >> primer_input.txt
                    echo "PRIMER_TASK=pick_detection_primers" >> primer_input.txt
                    echo "PRIMER_PICK_LEFT_PRIMER=1" >> primer_input.txt
                    echo "PRIMER_PICK_INTERNAL_OLIGO=1" >> primer_input.txt
                    echo "PRIMER_PICK_RIGHT_PRIMER=1" >> primer_input.txt
                    echo "PRIMER_PRODUCT_SIZE_RANGE=100-300" >> primer_input.txt
                    echo "=" >> primer_input.txt
                    # Perform the primer design command
                    primer3_core primer_input.txt > primers.txt
                    echo "Primers designed and saved to primers.txt."
                else
                    echo "File not found. Please enter a valid file path."
                fi
                ;;
            4)
                # Break case statement to return to previous menu.
                break
                ;;
            5)
                # Exiting the progrem.
                echo "Exiting..."
                sleep 2
                exit 0
                ;;
            *)
                # if the user entering invalid option.
                echo "Invalid input. Please select a valid option."
                ;;
        esac
    done
}

while true; do

    echo "---------------------WELCOME TO AUTO TEAM PROGRAM---------------------"

    echo "What can I help you with?: (Choose By Number)"
    echo ""
    echo "1. BLAST: PAIRWISE SEQUENCE ALIGNMENT."
    echo "2. MULTIPL SEQUENCE ALIGNMENT AND PHYLOGENETIC TREE."
    echo "3. PRIMER DESIGN."
    echo "4. HELP!....BEFOR START...."
    echo "5. EXIT PROGRAM."
    read -p "choose the tool: " tool

    case $tool in
        1)
            echo "BLAST: (PAIRWISE SEQUENCE ALIGNMENT)."
            run_blast
            ;;
        2)
            echo "MULTIPL SEQUENCE ALIGNMENT AND PHYLOGENETIC TREE."
            run_msa
            ;;
        3)
            echo "PRIMER DESIGN."
            run_primer_design
            ;;
        4)
            echo "---------------------HELP---------------------"
            echo "Getting help...."
            echo "1. To use this program choose the tool you want to use by entering the number corresponding to the tool."
            echo "2. Follow the prompts to enter the required information for each tool."
            echo "3. All modes of input files in this program must be changed to (+x) to make it excutable."
            echo "4. To run all tools in this program you mus install some tools and here is the url of each tool: "
            echo "        efetch:     https://www.ncbi.nlm.nih.gov/books/NBK179288/"
            echo "        blast:      https://blast.ncbi.nlm.nih.gov/doc/blast-help/downloadblastdata.html"
            echo "        mafft:      https://mafft.cbrc.jp/alignment/software/source.html"
            echo "        muscle:     https://www.drive5.com/muscle/manual/install.html"
            echo "        phyml:      https://bioweb.pasteur.fr/docs/modules/phyml/3.0.1/phyml_manual_2008.pdf"
            echo "        seaview:    https://howtoinstall.co/package/seaview"
            echo "        seqmagic:   https://launchpad.net/ubuntu/focal/+source/seqmagick"
            echo "        figtree:    http://tree.bio.ed.ac.uk/software/figtree/"
            echo "5. note that the all parameter of these tools set as default and if you want to change any parameter use command (man $tool_name)."
            ;;
        5)
            echo "Exiting..."
            sleep 2
            exit 0
            ;;
        *)
            echo "Invalid input. Please enter a valid number."
            ;;
    esac
done
