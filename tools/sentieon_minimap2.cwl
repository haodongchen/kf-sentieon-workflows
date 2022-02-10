cwlVersion: v1.2
class: CommandLineTool
label: Sentieon_minimap2
doc: |-
  The Sentieon **minimap2** binary performs alignment of PacBio or Oxford Nanopore genomic reads data and will behave the same way as the tool described in [https://github.com/lh3/minimap2](https://github.com/lh3/minimap2) (2.22-r1101). This App outputs the sorted BAM.
  
  ### Inputs:
  - ``Reference``: Location of the reference FASTA file (Required)
  - ``Input reads``: Files containing reads (Required)

  
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
            return 32
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
            return 32000
        }
    }
- class: DockerRequirement
  dockerPull: pgc-images.sbgenomics.com/hdchen/sentieon:202112.01_hifi
- class: EnvVarRequirement
  envDef:
  - envName: SENTIEON_LICENSE
    envValue: $(inputs.sentieon_license)
- class: InlineJavascriptRequirement

inputs:
- id: sentieon_license
  label: Sentieon license
  doc: License server host and port
  type: string
- id: reference
  label: Reference or Reference Index
  doc: |-
    Reference file or minimap reference index. Beware that indexing options are fixed in the index file. When an index file is provided as the target sequences, options -H, -k, -w, -I will be effectively overridden by the options stored in the index file.
  type: File
  inputBinding:
    position: 98
    shellQuote: false
  sbg:fileTypes: FA, MMI, FASTA
- id: in_reads
  label: Input reads
  doc: File or files containing reads.
  type: File[]
  inputBinding:
    position: 99
    shellQuote: false
  sbg:fileTypes: FQ, FASTQ, FQ.GZ, FASTQ.GZ
- id: output_name
  label: Output file name
  doc: |-
    Desired output file name (without an extension). If not filled, output file is named based on sample ID metadata, if that is not present, output name is generated based on input read names.
  type: string?
- id: output_type
  label: Output file type
  doc: |-
    Output alignments in BAM or in PAF format. Setting this parameter to BAM, prefix '-a' is added to the command line and the output will be sorted. Default is PAF.
  type:
  - 'null'
  - name: output_type
    type: enum
    symbols:
    - BAM
    - PAF
  default: BAM
  sbg:toolDefaultValue: 'BAM'
- id: preset_options
  label: Preset options
  doc: |-
    Select one of the preset options prepared by the tool authors. Selecting one of these options will apply multiple options at the same time. It should be applied before other options because options applied later will overwrite the values set.
  type:
  - 'null'
  - name: preset_options
    type: enum
    symbols:
    - map-pb
    - map-ont
    - asm5
    - asm10
    - asm20
    - ava-pb
    - ava-ont
    - splice
    - splice:hq
    - sr
    - map-hifi
  inputBinding:
    prefix: -x
    position: 0
    shellQuote: false
- id: matching_score
  label: Matching score
  doc: Matching score. Default is 2.
  type: int?
  inputBinding:
    prefix: -A
    position: 1
    shellQuote: false
  sbg:category: Alignment options
  sbg:toolDefaultValue: '2'
- id: mismatch_penalty
  label: Mismatch penalty
  doc: Mismatch penalty
  type: int?
  inputBinding:
    prefix: -B
    position: 1
    shellQuote: false
  sbg:category: Alignment options
  sbg:toolDefaultValue: '4'
- id: gap_open_penalty
  label: Gap open penalty
  doc: 'Gap open penalty [default: 4,24]. If INT2 is not specified, it is set to INT1.'
  type: int[]?
  inputBinding:
    prefix: -O
    position: 1
    itemSeparator: ','
    shellQuote: false
  sbg:toolDefaultValue: 4,24
- id: gap_extension_penalty
  label: Gap extension penalty
  doc: |-
    Gap extension penalty [default: 2,1]. A gap of length k costs min{O1+k*E1,O2+k*E2}. In the splice mode, the second gap penalties are not used.
  type: int[]?
  inputBinding:
    prefix: -E
    position: 1
    itemSeparator: ','
    shellQuote: false
  sbg:category: Alignment options
  sbg:toolDefaultValue: 2,1
- id: zdrop
  label: Z Drop
  doc: |-
    Truncate an alignment if the running alignment score drops too quickly along the diagonal of the DP matrix (diagonal X-drop, or Z-drop) [400,200].
  type: int[]?
  inputBinding:
    prefix: -z
    position: 1
    itemSeparator: ','
    shellQuote: false
  sbg:category: Alignment options
  sbg:toolDefaultValue: 400,200
- id: min_dp_score
  label: Minimal peak DP alignment score
  doc: |-
    Minimal peak DP alignment score to output [default: 40]. The peak score is computed from the final CIGAR. It is the score of the max scoring segment in the alignment and may be different from the total alignment score.
  type: int?
  inputBinding:
    prefix: -s
    position: 1
    shellQuote: false
  sbg:category: Alignment options
  sbg:toolDefaultValue: '40'
- id: write_cigar
  label: Write CIGAR to cg tag
  doc: |-
    Write CIGAR with >65535 operators at the CG tag. Older tools are unable to convert alignments with >65535 CIGAR ops to BAM. This option makes minimap2 SAM compatible with older tools. Newer tools recognizes this tag and reconstruct the real CIGAR in memory.
  type: boolean?
  inputBinding:
    prefix: -L
    position: 1
    shellQuote: false
  sbg:category: Input/output options
- id: copy_comments
  label: Copy comments
  doc: Copy input FASTA/Q comments.
  type: boolean?
  inputBinding:
    prefix: -y
    position: 1
    shellQuote: false
  sbg:toolDefaultValue: Input/output options
- id: read_group_line
  label: Read group line
  doc: SAM read group line in a format like '@RG\tID:foo\tSM:bar\tPL:PacBio'
  type: string?
  inputBinding:
    prefix: -R
    position: 1
    shellQuote: false
- id: create_cigar
  label: Generate cigar
  doc: Generate CIGAR. In PAF, the CIGAR is written to the 'cg' custom tag.
  type: boolean?
  inputBinding:
    prefix: -c
    position: 1
    shellQuote: false
  sbg:category: Input/output options
- id: ouput_cs_tag
  label: Output cs tag
  doc: |-
    Output the cs tag. STR can be either short or long. If no STR is given, short is assumed. [default: none]
  type:
  - 'null'
  - name: ouput_cs_tag
    type: enum
    symbols:
    - short
    - long
  inputBinding:
    prefix: -cs=
    position: 1
    separate: false
    shellQuote: false
- id: md_tag
  label: Output MD tag
  doc: Output the MD tag (see the SAM spec).
  type: boolean?
  inputBinding:
    prefix: --MD
    position: 1
    shellQuote: false
  sbg:toolDefaultValue: Input/output options
- id: eqx
  label: Output CIGAR operators
  doc: Output =/X CIGAR operators for sequence match/mismatch.
  type: boolean?
  inputBinding:
    prefix: --eqx
    position: 1
    shellQuote: false
  sbg:category: Input/output options
- id: soft_clipping
  label: Soft clipping in SAM
  doc: In SAM output, use soft clipping for supplementary alignments.
  type: boolean?
  inputBinding:
    prefix: -Y
    position: 1
    shellQuote: false
  sbg:category: Input/output options
- id: minibatch_size
  label: Minibatch size
  doc: |-
    Number of bases loaded into memory to process in a mini-batch [500M].
  type: string?
  inputBinding:
    prefix: -K
    position: 1
    shellQuote: false
  sbg:toolDefaultValue: '500M'
- id: additional_inputs
  label: Additional arguments
  doc: |-
    Optional input for additional arguments.
  type: string?
  inputBinding:
    position: 97
    shellQuote: false
- id: cpu_per_job
  label: CPU per job
  doc: CPU per job
  type: int?
- id: mem_per_job
  label: Memory per job
  doc: Memory per job[MB]
  type: int?

outputs:
- id: out_alignments
  label: Out alignments
  doc: Output alignment file in PAF or BAM format.
  type: File?
  outputBinding:
    glob: '{*.paf,*.bam,*.bai}'
  sbg:fileTypes: PAF, BAM

baseCommand:
- sentieon
- minimap2
arguments:
- prefix: ''
  position: 1
  valueFrom: "${\n    if (inputs.output_type == 'BAM'){\n        return '-a'\n   \
    \ }\n}"
  shellQuote: false
- prefix: ''
  position: 1
  valueFrom: $("-t $(nproc)")
  shellQuote: false
- prefix: ''
  position: 101
  valueFrom: |-
    ${
        if (inputs.output_type == 'BAM'){
            return ' | sentieon util sort -i - --sam2bam '
        }
    }
  shellQuote: false
- prefix: -o
  position: 200
  valueFrom: |-
    ${
        // generate output file name
        var out_name = ""
        var ext = ""
        
        if (inputs.output_name)
        {
            out_name = inputs.output_name
        }
        else 
        {
            var reads = [].concat(inputs.in_reads)
            if ((reads[0].metadata) && (reads[0].metadata['sample_id'])) 
            {
                out_name = reads[0].metadata['sample_id']
            }
            else 
            {
                out_name = reads[0].nameroot
            }
        }
        
        if (inputs.output_type == 'BAM'){
            ext = '.bam'
            
        } else {
            ext = '.paf'
        }
         
        return out_name + ext
    }
  shellQuote: false
