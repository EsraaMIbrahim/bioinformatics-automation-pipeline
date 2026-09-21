#!/bin/bash


# function to retrieve data from a bioinformatics database
function retrieve_data() {
    database=$1
    search_criteria=$2

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
            echo "Unsupported database. Please enter a database from the following NCBI, Ensemble, UniProt: $database"
            ;;
    esac
}

function retrieve_from_ncbi() {
    database_type=$1
    search_criteria=$2

    case $database_type in
        "gene")
            curl "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=gene&id=$search_criteria&rettype=fasta&retmode=text"
            ;;
        "nucleotide")
            curl "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nucleotide&id=$search_criteria&rettype=fasta&retmode=text"
            ;;
        "protein")
            curl "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=protein&id=$search_criteria&rettype=fasta&retmode=text"
            ;;
        *)
            echo "Unsupported NCBI database type: $database_type"
            ;;
    esac
}

function retrieve_from_ensembl() {

    search_criteria=$1

    curl "https://rest.ensembl.org/lookup/id/$search_criteria?content-type=text/x-fasta"

}



function retrieve_from_uniprot() {

    search_criteria=$1

    curl  "https://www.uniprot.org/uniprotkb/$search_criteria.fasta"
}



# main script

while true; do
    echo "Welcome to the Bioinformatics Tool"
    echo "1. Select the bioinformatics database:"
    echo "   1. NCBI"
    echo "   2. Ensembl"
    echo "   3. UniProt"
    echo "2. Exit"

    read -p "Enter your choice: " choice

    case $choice in
        1)
            read -p "Enter the database number: " database_number
            case $database_number in
                1)
                    database="NCBI"
                    echo "Select the NCBI database type: " 
                    echo "1. gene"
                    echo "2. nucleotide"
                    echo "3. protein"

                    read -r choice
                    case $choice in
                        1)
                            selected_ncbi_db="gene"
                            ;;
                        2)
                            selected_ncbi_db="nucleotide"
                            ;;
                        3)
                            selected_ncbi_db="protein"
                            ;;
                        *)
                            echo "Invalid choice. Please enter a valid option."
                            ;;
                    esac
                    ;;
                2)
                    database="Ensembl"
                    ;;
                3)
                    database="UniProt"
                    ;;
                *)
                    echo "Invalid database number. Please enter a valid choice."
                    continue
                    ;;
            esac

            read -p "Enter the search criteria: " search_criteria
            retrieve_data "$database" "$search_criteria"
            ;;
        2)
            echo "Exiting the program..."
            exit 0
            ;;
        *)
            echo "Invalid choice. Please enter a valid option."
            ;;
    esac

    echo "Press Enter to return to the main menu or enter 'q' to quit."
    read -r response

    if [ "$response" = "q" ]; then
      exit 0
    fi
    clear
done
