#!/usr/bin/env bash

# Heterozygous loci caller
#
# Syntax:
#   call_hetloci.sh <ref_fasta> <alignment_bam> <out_dir>
#
# Author: Dennis Aldea <dennisaldea@cmu.edu> 

genome_fa=$1
alignment_bam=$2
output_dir=$3

current_dir="$(pwd)"
if [[ ! -e "$output_dir" ]]; then
  mkdir "$output_dir"
fi
cd "$output_dir"
genome_fa="../$genome_fa"
alignment_bam="../$alignment_bam"

sample_name="$(basename $alignment_bam)"
sample_name="${sample_name%.*}"

rawcalls_vcf="${sample_name}_rawcalls.vcf.gz"
bcftools mpileup -Ou -f "$genome_fa" "$alignment_bam" \
| bcftools call -mv -Oz -o "$rawcalls_vcf"
bcftools index "$rawcalls_vcf"

hetsnps_vcf="${sample_name}_hetsnps.vcf.gz"
bcftools view -i 'TYPE="snp" && GT="het" && QUAL>=30 && DP>=10' \
  -Oz -o "$hetsnps_vcf" "$rawcalls_vcf"
bcftools index "$hetsnps_vcf"

alleles_vcf="${sample_name}_alleles.vcf.gz"
bcftools mpileup -f "$genome_fa" -a AD -Ou "$alignment_bam" \
  | bcftools call -mv -Oz -o "$alleles_vcf"
bcftools index "$alleles_vcf"

# Keep heterozygous loci with approximately even balance and depth
hetloci_bed="${sample_name}_hetloci.bed"
bcftools view -i 'TYPE="snp" && GT="het"' "$alleles_vcf" \
| bcftools query -f '%CHROM\t%POS\t%REF\t%ALT[\t%SAMPLE\t%AD]\n' \
| awk -F'\t' '
  function abs(x){return x<0?-x:x}
  {
    # AD like "ref,alt" appears at the end of the line for single-sample VCF
    split($NF,a,","); ref=a[1]+0; alt=a[2]+0; tot=ref+alt
    if (tot>=10) {
      p=alt/tot
      if (p>=0.2 && p<=0.8 && ref>=3 && alt>=3)
        print $1"\t"$2-1"\t"$2   # 0-based BED point intervals
    }
  }' > "$hetloci_bed"

cd "$current_dir"
