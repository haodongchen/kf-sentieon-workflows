cwlVersion: v1.2
class: CommandLineTool
label: Sentieon_DNAscope_LongRead
doc: |-
  This tool uses **Sentieon DNAscope** to call germline variants from PacBio HiFi or ONT reads [1].

  ### Input data requirements

  - **Aligned reads**: The pipeline will take PacBio HiFi or ONT reads that have been aligned to a reference genome with `pbmm2` or `minimap2`.
  - **The Reference genome**: A reference genome file in FASTA format with its index file (.fai). 
  - **DNAscope model bundle**: DNAscope model.

  ### Common Issues and Important Notes

  * Currently, the pipeline is only recommended for use with samples from diploid organisms. For samples with both diploid and haploid chromosomes, the `-b INTERVAL` option can be used to limit variant calling to diploid chromosomes.

  ###References

  [1] [https://support.sentieon.com/appnotes/dnascope_hifi/](https://support.sentieon.com/appnotes/dnascope_hifi/)

$namespaces:
  sbg: https://sevenbridges.com

requirements:
- class: ShellCommandRequirement
- class: ResourceRequirement
  coresMin: |-
    ${
        if (inputs.cpu_per_job)
        {
            return inputs.cpu_per_job
        }
        else
        {
            return 36
        }
    }
  ramMin: |-
    ${
        if (inputs.mem_per_job)
        {
            return inputs.mem_per_job
        }
        else
        {
            return 71000
        }
    }
- class: DockerRequirement
  dockerPull: pgc-images.sbgenomics.com/hdchen/sentieon:202308.02
- class: EnvVarRequirement
  envDef:
  - envName: SENTIEON_LICENSE
    envValue: $(inputs.sentieon_license)
- class: InitialWorkDirRequirement
  listing:
    - entryname: dnascope_HiFi.sh
      entry:
        $include: ../scripts/dnascope_HiFi.sh
    - entryname: dnascope_ONT.sh
      entry:
        $include: ../scripts/dnascope_ONT.sh
    - entryname: gvcf_combine.py
      entry:
        $include: ../scripts/gvcf_combine.py
    - entryname: vcf_mod.py
      entry:
        $include: ../scripts/vcf_mod.py
inputs:
- id: sentieon_license
  label: Sentieon license
  doc: License server host and port
  type: string
- id: platform
  label: Platform
  type:
    - type: enum
      symbols:
        - HiFi
        - ONT
- id: model_bundle
  label: DNAscope model bundle
  type: File
  inputBinding:
    prefix: -m
    position: 10
- id: reference
  label: Reference
  doc: Reference fasta with associated fai index
  type: File
  secondaryFiles:
  - pattern: .fai
    required: true
  - pattern: ^.dict
    required: false
  inputBinding:
    prefix: -r
    position: 10
  sbg:fileTypes: FA, FASTA
- id: input_bam
  label: Input BAM
  doc: Input BAM file
  type: File
  secondaryFiles:
  - pattern: ^.bai
    required: false
  - pattern: ^.crai
    required: false
  - pattern: .bai
    required: false
  - pattern: .crai
    required: false
  inputBinding:
    prefix: -i
    position: 11
  sbg:fileTypes: BAM, CRAM
- id: output_file_name
  label: Output file name
  doc: The output VCF file name. Must end with ".gz".
  type: string?
- id: dbSNP
  label: dbSNP VCF file
  doc: |-
    Supplying this file will annotate variants with their dbSNP refSNP ID numbers. (optional)
  type: File?
  secondaryFiles:
  - pattern: .tbi
    required: false
  - pattern: .idx
    required: false
  inputBinding:
    prefix: -d
    position: 30
- id: bed
  label: Region BED file
  doc: |-
    Supplying this file will limit variant calling to the intervals inside the BED file. (optional)
  type: File?
  inputBinding:
    prefix: -b
    position: 39
  sbg:fileTypes: BED
- id: output_gvcf
  label: Output gVCF
  doc: Generate a gVCF output file along with the VCF. Default generates only the VCF
  type: boolean?
  default: false
  inputBinding:
    prefix: -g
    position: 40
- id: cpu_per_job
  label: CPU per job
  doc: CPU per job
  type: int?
- id: mem_per_job
  label: Memory per job
  doc: Memory per job[MB]
  type: int?

outputs:
- id: output_vcf
  type:
  - type: array
    items: File
  secondaryFiles:
  - pattern: .tbi
    required: true
  outputBinding:
    glob: '*vcf.gz'

baseCommand:
- /bin/bash
arguments:
- position: 1
  valueFrom: |-
    ${
        return "dnascope_" + inputs.platform + ".sh"
    }
  shellQuote: false
- prefix: ''
  position: 100
  valueFrom: |-
    ${
        if (inputs.output_file_name)
            return inputs.output_file_name
        else
            var basename = inputs.input_bam.nameroot
            return basename.concat(".vcf.gz")
    }
  shellQuote: false
