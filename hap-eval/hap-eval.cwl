cwlVersion: v1.2
class: CommandLineTool
label: Hap-Eval
doc: |-
  Comparison engine for structual variant benchmarking.
  
  ### Inputs:
  #### Required
  - ``Reference``: Location of the reference FASTA file.
  - ``Baseline``: Location of the Baseline vcf file.
  - ``Comparison``: Location of the Comparison vcf file.
  
  ### Usage:
  ```yaml
        usage: hap_eval [-h] -r FASTA -b VCF -c VCF [-i BED] [-t INT] [--base_out VCF]
                        [--comp_out VCF] [--maxdist INT] [--minsize INT]
                        [--maxdiff FLOAT] [--metric STR]
        optional arguments:
          -h, --help            show this help message and exit
          -r FASTA, --reference FASTA
                                Reference file
          -b VCF, --base VCF    Baseline vcf file
          -c VCF, --comp VCF    Comparison vcf file
          -i BED, --interval BED
                                Evaluation region file
          -t INT, --thread_count INT
                                Number of threads
          --base_out VCF        Annotated baseline vcf file
          --comp_out VCF        Annotated comparison vcf file
          --maxdist INT         Maximum distance to cluster variants (default: 1000)
          --minsize INT         Minimum size of variants to consider (default: 50)
          --maxdiff FLOAT       Haplotype difference theshold (default: 0.2)
          --metric STR          Distance metric (default: Levenshtein)

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
            return 8
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
            return 8000
        }
    }
- class: DockerRequirement
  dockerPull: pgc-images.sbgenomics.com/hdchen/hap-eval:latest
- class: InlineJavascriptRequirement

stdout: |-
    ${
        if (inputs.out_table_name)
        {
            return inputs.out_table_name
        }
        else
        {
            return "output.txt"
        }
    }

inputs:
- id: reference
  label: Reference
  doc: Reference fasta with associated fai index
  type: File
  secondaryFiles:
  - pattern: .fai
    required: true
  - pattern: ^.dict
    required: true
  inputBinding:
    prefix: -r
    position: 0
    shellQuote: false
  sbg:fileTypes: FA, FASTA
- id: base
  label: Baseline
  doc: Baseline vcf file
  type: File
  secondaryFiles:
  - pattern: .tbi
    required: false
  - pattern: .idx
    required: false
  inputBinding:
    prefix: --base
    position: 1
    shellQuote: false
  sbg:fileTypes: VCF, VCF.GZ
- id: comp
  label: Comparison
  doc: Comparison vcf file
  type: File
  secondaryFiles:
  - pattern: .tbi
    required: false
  - pattern: .idx
    required: false
  inputBinding:
    prefix: --comp
    position: 2
    shellQuote: false
  sbg:fileTypes: VCF, VCF.GZ
- id: interval
  label: Interval
  doc: Evaluation region file
  type: File?
  inputBinding:
    prefix: --interval
    position: 5
    shellQuote: false
  sbg:fileTypes: BED
- id: base_out
  label: Base VCF OUT
  doc: Annotated baseline vcf file. Must end with ".vcf.gz".
  type: string?
  inputBinding:
    prefix: --base_out
    position: 10
    shellQuote: false
- id: comp_out
  label: Comp VCF OUT
  doc: Annotated comparison vcf file. Must end with ".vcf.gz".
  type: string?
  inputBinding:
    prefix: --comp_out
    position: 10
    shellQuote: false
- id: maxdist
  label: Maximum distance
  doc: |-
    Maximum distance to cluster variants (default: 1000)
  type: int?
  inputBinding:
    prefix: --maxdist
    position: 20
    shellQuote: false  
  default: 1000
- id: minsize
  label: Minimum size of variants
  doc: |-
    Minimum size of variants to consider (default: 50)
  type: int?
  inputBinding:
    prefix: --minsize
    position: 20
    shellQuote: false  
  default: 50  
- id: maxdiff
  label: Maximum diff
  doc: |-
    Haplotype difference theshold (default: 0.2)
  type: float?
  inputBinding:
    prefix: --maxdiff
    position: 20
    shellQuote: false  
  default: 0.2
- id: metric
  label: Metric
  doc: |-
    Distance metric (default: Levenshtein)
  type: string?
  inputBinding:
    prefix: --metric
    position: 20
    shellQuote: false  
  default: Levenshtein
- id: out_table_name
  label: Output name
  type: string?
- id: cpu_per_job
  label: CPU per job
  doc: CPU per job
  type: int?
- id: mem_per_job
  label: Memory per job
  doc: Memory per job[MB].
  type: int?
  
outputs:
- id: result
  type: stdout
- id: annotated_vcfs
  type: File
  outputBinding:
    glob: '*vcf*'

baseCommand:
- hap_eval
