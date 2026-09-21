#!/bin/bash

# Perform sequence alignment manually function
perform_sequence_alignment_manually() {
  query_sequence="$1"
  subject_sequence="$2"
  alignment_type="$3"

  # Create temporary files for the query and subject sequences
  query_file=$(mktemp)
  subject_file=$(mktemp)

  # Save the query and subject sequences to the temporary files
  echo -e ">Query\n$query_sequence" > "$query_file"
  echo -e ">Subject\n$subject_sequence" > "$subject_file"

  # Perform BLAST sequence alignment based on the alignment type
  case $alignment_type in
    p)
      blastp -query "$query_file" -subject "$subject_file"
      ;;
    n)
      blastn -query "$query_file" -subject "$subject_file"
      ;;
    x)
      blastx -query "$query_file" -subject "$subject_file"
      ;;
    *)
      echo "Invalid alignment type"
      ;;
  esac
  # Clean up temporary files
  rm "$query_file" "$subject_file"
}

# Perform sequence alignment from file function
perform_sequence_alignment_file(){
  query_file="$1"
  subject_file="$2"
  alignment_type="$3"

  # Perform BLAST sequence alignment based on the alignment type
  case $alignment_type in
    p)
      blastp -query "$query_file" -subject "$subject_file"
      ;;
    n)
      blastn -query "$query_file" -subject "$subject_file"
      ;;
    x)
      blastx -query "$query_file" -subject "$subject_file"
      ;;
    *)
      echo "Invalid alignment type"
      ;;
  esac
}

# Retrieve sequence from NCBI function
retrieve_sequence_from_ncbi() {
  database_type="$1"
  search_criteria="$2"

  case $database_type in
    "gene")
      sequence=$(curl "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=gene&id=$search_criteria&rettype=fasta&retmode=text")
      if echo "$sequence" | grep -q ">seq"; then
        echo "$sequence"
      else
        echo "Error: Invalid sequence format"
      fi
      ;;
    "protein")
      curl "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=protein&id=$search_criteria&rettype=fasta&retmode=text"
      ;;
    "nucleotide")
      sequence=$(curl "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nucleotide&id=$search_criteria&rettype=fasta&retmode=text")
      if echo "$sequence" | grep -q ">seq"; then
        echo "$sequence"
      else
        echo "Error: Invalid sequence format"
      fi
      ;;
    *)
      echo "Invalid database type"
      ;;
  esac
}
# Main menu loop
while true; do
  echo "Choose an input method:"
  echo "1. Enter sequences manually"
  echo "2. Specify a file containing sequences"
  echo "3. Download sequence from NCBI"
  echo "4. Quit"
  read -p "Enter your choice: " input_method

  case $input_method in
    1)
      # Read sequences from user input
      echo "Please Enter the sequences in one line "
      echo "Enter the query sequence:"
      read -r query_sequence
      echo "Enter the subject sequence:"
      read -r subject_sequence
      echo "Enter the alignment type BLAST (p/n/x):"
      read -r alignment_type
      perform_sequence_alignment_manually "$query_sequence" "$subject_sequence" "$alignment_type"
      ;;
    2)
      # Prompt the user to enter the file paths
      echo "Enter the path to the file containing the query sequence:"
      read -r input_query_file
      echo "Enter the path to the file containing the subject sequence:"
      read -r input_subject_file
      echo "Enter the alignment type BLAST (p/n/x):"
      read -r alignment_type
      if [ -n "$input_query_file" ] && [ -n "$input_subject_file" ] && [ -f "$input_query_file" ] && [ -f "$input_subject_file" ]; then
        # Read sequences from the specified file
        perform_sequence_alignment_file "$input_query_file" "$input_subject_file" "$alignment_type"
      else
        echo "Invalid file (the file is either empty or does not exist)"
        exit 0
      fi
      ;;
    3)
      # Download sequence from NCBI
      echo "Choose the database type:"
      echo "1. Gene"
      echo "2. Protein"
      echo "3. Nucleotide"
      echo "4. Nucleotide/Protein (for Blastx)"
      read -r database_option

      case $database_option in
        1)
          database_type="gene"
          echo "Enter the gene accession number for the query sequence:"
          read -r query_search_criteria
          echo "Enter the gene accession number for the subject sequence:"
          read -r subject_search_criteria

          query_sequence=$(retrieve_sequence_from_ncbi "$database_type" "$query_search_criteria")
          subject_sequence=$(retrieve_sequence_from_ncbi "$database_type" "$subject_search_criteria")

          if [[ -z "$query_sequence" || -z "$subject_sequence" ]]; then
            echo "Failed to retrieve oneof the sequences from NCBI. Please check your input and try again."
            exit 0
          fi

          echo "Enter the alignment type BLAST (p/n/x):"
          read -r alignment_type
          perform_sequence_alignment_manually "$query_sequence" "$subject_sequence" "$alignment_type"

          ;;
        2)
          database_type="protein"
          echo "Enter the protein accession number for the query sequence:"
          read -r search_criteria
          echo "Enter the protein accession number for the subject sequence:"
          read -r subject_search_criteria

          query_sequence=$(retrieve_sequence_from_ncbi "$database_type" "$query_search_criteria")
          subject_sequence=$(retrieve_sequence_from_ncbi "$database_type" "$subject_search_criteria")

          if [[ -z "$query_sequence" || -z "$subject_sequence" ]]; then
            echo "Failed to retrieve one of the sequences from NCBI. Please check your input and try again."
            exit 0
          fi

          echo "Enter the alignment type BLAST (p/n/x):"
          read -r alignment_type
          perform_sequence_alignment_manually "$query_sequence" "$subject_sequence" "$alignment_type"
          ;;
        3)
          database_type="nucleotide"
          echo "Enter the nucleotide accession number for the query sequence:"
          read -r search_criteria
          echo "Enter the nucleotide accession number for the subject sequence:"
          read -r subject_search_criteria

          query_sequence=$(retrieve_sequence_from_ncbi "$database_type" "$query_search_criteria")
          subject_sequence=$(retrieve_sequence_from_ncbi "$database_type" "$subject_search_criteria")

          if [[ -z "$query_sequence" || -z "$subject_sequence" ]]; then
            echo "Failed to retrieve one of the sequences from NCBI. Please check your input and try again."
            exit 0
          fi

          echo "Enter the alignment type BLAST (p/n/x):"
          read -r alignment_type
          perform_sequence_alignment_manually "$query_sequence" "$subject_sequence" "$alignment_type"
          ;;
        4)
          database_type="nucleotide"
          echo "Enter the nucleotide accession number for the query sequence:"
          read -r search_criteria
          query_sequence=$(retrieve_sequence_from_ncbi "$database_type" "$query_search_criteria")

          database_type="protein"
          echo "Enter the protein accession number for the query sequence:"
          read -r search_criteria
          subject_sequence=$(retrieve_sequence_from_ncbi "$database_type" "$subject_search_criteria")
          alignment_type="x"
          perform_sequence_alignment_manually "$query_sequence" "$subject_sequence" "$alignment_type"
          ;;
        *)
          echo "Invalid database option"
          ;;
      esac
      ;;
    4)
      # Exit the script
      exit 0
      ;;
    *)
      echo "Invalid input method. Please choose a valid option."
      ;;
  esac

  echo "Press Enter to return to the main menu or enter 'q' to quit."
  read -r response

  if [ "$response" = "q" ]; then
    exit 0
  fi

  clear
done
