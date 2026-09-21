#!/bin/bash

while true; do 
    # Asking user about input file.
    echo "1. Design primers from a FASTA file."
    echo "2. Design primers for a sequence by accession number."
    echo "3. Design primers from a FASTQ file."
    echo "4. Return to the main menu."
    echo "5. Exit."
    read file_type
    
    case $file_type in 
        1)
            # if the user have fasta file includes sequence.
            echo "Please enter the path to the input FASTA file:"
            read input_file
            if [ -f "$input_file" ]; then
                output_file="primer_input.txt"
# Run Primer3
primer3_core << EOF > "$output_file"
$(echo "SEQUENCE_ID=$(grep "^>" "$input_file" | sed 's/^>//')")
$(echo "SEQUENCE_TEMPLATE=$(grep -v "^>" "$input_file" | tr -d '\n')")
PRIMER_TASK=pick_detection_primers
PRIMER_PICK_LEFT_PRIMER=1
PRIMER_PICK_INTERNAL_OLIGO=1
PRIMER_PICK_RIGHT_PRIMER=1
PRIMER_PRODUCT_SIZE_RANGE=100-300
EOF
                # Perform the primer design command
                primer3_core "$output_file" > primers.txt
                echo "Primers designed and saved to primers.txt."
            else
                echo "File not found. Please enter a valid file path."
            fi
            ;;
        2)
            # if the user wan to efetching sequence by accession number.
            echo "Enter the accession number: "
            read accession_p
            if [ -n "$accession_p" ]; then
efetch -db nuccore -id "$accession_p" -format fasta > input_file
output_file="primer_input.txt"
# Run Primer3
primer3_core << EOF > "$output_file"
$(echo "SEQUENCE_ID=$(grep "^>" "$input_file" | sed 's/^>//')")
$(echo "SEQUENCE_TEMPLATE=$(grep -v "^>" "$input_file" | tr -d '\n')")
PRIMER_TASK=pick_detection_primers
PRIMER_PICK_LEFT_PRIMER=1
PRIMER_PICK_INTERNAL_OLIGO=1
PRIMER_PICK_RIGHT_PRIMER=1
PRIMER_PRODUCT_SIZE_RANGE=100-300
EOF
                # Perform the primer design command
                primer3_core "$output_file" > primers.txt
                echo "Primers designed and saved to primers.txt."
            else
                echo "Invalid input. Please enter a valid accession number."
            fi
            ;;
        3)
            # convert FASTQ to FASTA 
            echo "Please enter the path to the input FASTQ file:"
            read input_fastq
            if [ -f "$input_fastq" ]; then
                sed -n '1~4s/^@/>/p;2~4p' $input_fastq > input_file
                output_file="primer_input.txt"
# Run Primer3
primer3_core << EOF > "$output_file"
$(echo "SEQUENCE_ID=$(grep "^>" "$input_file" | sed 's/^>//')")
$(echo "SEQUENCE_TEMPLATE=$(grep -v "^>" "$input_file" | tr -d '\n')")
PRIMER_TASK=pick_detection_primers
PRIMER_PICK_LEFT_PRIMER=1
PRIMER_PICK_INTERNAL_OLIGO=1
PRIMER_PICK_RIGHT_PRIMER=1
PRIMER_PRODUCT_SIZE_RANGE=100-300
EOF
                # Perform the primer design command
                primer3_core "$output_file" > primers.txt
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

