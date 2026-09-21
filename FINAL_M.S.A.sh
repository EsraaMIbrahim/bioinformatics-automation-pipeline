#!/bin/bash

while true; do
    # Asking user for M.S.A tools.
    echo "Please Choose the M.S.A tool: "
    echo "1. MUSCLE."
    echo "2. MAFFT."
    echo "3. Visualize the Result.( After Performing M.S.A )"
    echo "4. Return to Main Menu."
    echo "5. EXIT!."
    read msa_tool

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
                read -r msa_input

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
                read -r msa_input

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
            read vis_num
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

