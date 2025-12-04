#!/usr/bin/env bash

#// Heterozygosity analysis pipeline
#//
#// Syntax:
#//     hetsnp_pl [-j <njobs>] [-o <outdir>] [-R <regions_bed>]
#//       <manifest> <genome_fna>
#//
#// Arguments:
#//     manifest: Samples manifest file
#//         A TSV file specifying the sample names and sample data files.
#//         See "Sample Manifest" in `README.md`.
#//     genome_fna: Genome reference FASTA file
#// 
#// Options:
#//   -R <regions_bed>: Genomic regions BED file
#//       If a regions bed file `<regions_bed>` is given, only alignments within
#//       the regions specified in `<region_bed>` will be analyzed.
#//   -j <njobs>: Maximum number of parallel processes
#//       (Default: total number of available processors)
#//   -o <outdir>: Output directory
#//       See "Output Files" in `README.md`. (Default: `./hetsnp_pl`)

# define options and default arguments
SCRIPTNAME="$(basename $0)"
SHORTOPTS="j:o:R:h"
OUTDIR_DEFAULT="./hetsnp_pl"
NUMPOSARGS=2

# set optional arguments to default values
nproc="$(nproc)"
outdir="$OUTDIR_DEFAULT"
# parse CLI using util-linux getopt
PARSEDCLI=$(getopt --options=$SHORTOPTS --name "$SCRIPTNAME" -- "$@") || exit 1
eval set -- "$PARSEDCLI"
# read parsed CLI for any specified options
while true; do
    case "$1" in
        -j) # [-j <numproc>]
            nproc="$2"
            shift 2
            ;;
        -o) # [-o <outdir>]
            outdir="$2"
            shift 2
            ;;
        -R) # [-R <regions_bed>]
            regions_bed="$2"
            shift 2
            ;;
        -h) # print help message and exit
            # the help message is all "#//" comments in this file
            echo "$0"
            grep "^#//" "$0" | cut -c 4-
            exit 0
            ;;
        --) # end of options
            shift
            break
            ;;
        *)  # unexpected option
            echo "Invalid option. Run `$SCRIPTNAME -h` for help." >&2
            exit 1
            ;;
    esac
done
# validate positional arguments
if [[ $# -lt $NUMPOSARGS ]]; then
    echo "Too few arguments. Run \`$SCRIPTNAME -h\` for help." >&2
    exit 1
elif [[ $# -gt $NUMPOSARGS ]]; then
    echo "Too many arguments. Run `$SCRIPTNAME -h` for help." >&2
    exit 1
fi
# parse positional arguments
manifest="$1"
genome_fna="$2"
shift 2

# [DEBUG]
if [[ -n $nproc ]]; then
    echo "nproc: $nproc"
else
    echo "nproc: (None)"
fi
if [[ -n $outdir ]]; then
    echo "outdir: $outdir"
else
    echo "outdir: (None)"
fi
if [[ -n $regions_bed ]]; then
    echo "regions_bed: $regions_bed"
else
    echo "regions_bed: (None)"
fi
echo "manifest: $manifest"
echo "genome_fna: $genome_fna"

#GENOME_FA="/home/dennis/CarjaLab/islandfoxes/ref/ucinereo/ucinereo.fna"
#
#ANALYSIS_DIR="/home/dennis/CarjaLab/islandfoxes/analysis4"
#ALIGNMENTS_DIR="$ANALYSIS_DIR/alignments"
#OUTPUT_DIR="$ANALYSIS_DIR/haplotypes"
#
#nproc=$1
#
#. "/home/dennis/.local/opt/miniconda3/etc/profile.d/conda.sh"
#conda activate genometools
#
#if [[ ! -e "$OUTPUT_DIR" ]]; then
#  mkdir "$OUTPUT_DIR"
#fi
#parallel_cmd="$HETLOCI_EXEC $GENOME_FA {} $OUTPUT_DIR"
#parallel -j $nproc --bar $parallel_cmd ::: $ALIGNMENTS_DIR/*.bam
#
#conda deactivate
