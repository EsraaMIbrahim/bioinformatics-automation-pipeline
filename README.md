# Bioinformatics Automation Pipeline (Bash)

An integrated, modular Bash automation tool designed to streamline end-to-end bioinformatics workflows on Linux environments without manual intervention.

---

## 🔬 Core Capabilities & Integrated Tools
- **NCBI Database Retrieval:** Direct sequence retrieval (Nucleotide/Protein/Gene) using Entrez Direct (`efetch` / `curl`).
- **Pairwise Alignment (BLAST):** Automated execution of `blastn`, `blastp`, and `blastx` against local databases or NCBI RefSeq genomes.
- **Multiple Sequence Alignment (MSA):** Automated alignment processing using `MUSCLE` and `MAFFT`, converted via `seqmagick`.
- **Phylogenetic Tree Construction:** Automated tree modeling using `PhyML` and visualization integration (`FigTree` / `SeaView`).
- **Primer Design:** Automated configuration and execution of `primer3_core` from FASTA / FASTQ formats.

---

## 🛠️ Tech Stack & Environment
`Bash Scripting` | `Linux CLI (Ubuntu)` | `NCBI-BLAST+` | `MUSCLE` | `MAFFT` | `PhyML` | `Primer3` | `Seqmagick`

---

## 💻 Execution
```bash
chmod +x AUTO_TEAM_SCRIPT.sh
./AUTO_TEAM_SCRIPT.sh
