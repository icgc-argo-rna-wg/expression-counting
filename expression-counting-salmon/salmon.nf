#!/usr/bin/env nextflow

/*
  Copyright (c) 2021, icgc-argo-rna-wg

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.

  Authors:
    DabinJeong
*/

/********************************************************************/
/* this block is auto-generated based on info from pkg.json where   */
/* changes can be made if needed, do NOT modify this block manually */
nextflow.enable.dsl = 2
version = '0.1.0'  // package version

container = [
    'n': 'n/n/expression-counting.expression-counting-salmon'
]
default_container_registry = 'n'
/********************************************************************/


// universal params go here
params.container_registry = ""
params.container_version = ""
params.container = ""

params.cpus = 1
params.mem = 1  // GB
params.publish_dir = ""  // set to empty string will disable publishDir


// tool specific parmas go here, add / change as needed
params.input_file = "tests/input/*_{1,2}.fastq.gz"
params.gtf = "tests/reference/*.annotation.gtf"
params.refRNAseq = "tests/reference/*.transcript.fa"
// output file name pattern 

inps_ch = Channel.fromFilePairs(params.input_file).ifEmpty{exit 1, "Fastq sequce not found: ${params.reads}"} 
transcriptome = file(params.refRNAseq)
annotation = file(params.gtf)


process expressionCountingSalmon {
  container "${params.container ?: container[params.container_registry ?: default_container_registry]}:${params.container_version ?: version}"
  publishDir "${params.publish_dir}/${task.process.replaceAll(':', '_')}", mode: "copy", enabled: params.publish_dir

  cpus params.cpus
  memory "${params.mem} GB"

  input:  // input, make update as needed
    tuple val(id), path(reads)
    path(transcriptome)
    file(annotation)

  output:  // output, make update as needed
    path "output_dir/${id}.salmon", emit: output_file

  script:
    // add and initialize variables here as needed

    """
    mkdir -p output_dir

    salmon index -t $transcriptome -i "salmon_index"
    salmon quant -i "salmon_index" --libType A -1 ${reads[0]} -2 ${reads[1]} -o $id 
    awk 'FS=OFS="\t" {if (\$1!~/#/) print \$9}' $annotation |grep "gene_id"|grep "transcript_id"|awk -F" |; " -vOFS="\t" '{print \$4, \$2}' > "${annotation}.tx2gene" 
    Rscript tx2gene.R --input $id/quant.sf --tx2gene "${annotation}.tx2gene" --tool salmon --output "${id}.salmon" 
    """
}


// this provides an entry point for this main script, so it can be run directly without clone the repo
// using this command: nextflow run <git_acc>/<repo>/<pkg_name>/<main_script>.nf -r <pkg_name>.v<pkg_version> --params-file xxx
workflow {
  expressionCountingSalmon(inps_ch, transcriptome, annotation)
}
