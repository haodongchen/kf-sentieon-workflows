cwlVersion: v1.2
class: CommandLineTool
label: generate_shards
$namespaces:
  sbg: https://sevenbridges.com

requirements:
- class: ShellCommandRequirement
- class: ResourceRequirement
  coresMin: 1
- class: DockerRequirement
  dockerPull: pgc-images.sbgenomics.com/d3b-bixu/ubuntu:18.04
- class: InitialWorkDirRequirement
  listing:
  - $(inputs.reference)
  - entryname: determine_shards.sh
    writable: false
    entry: |-
      fai="$1"
      step="$2"
      pos=1
      head -n 25 $fai | \
      while read chr len other; do
          while [ $pos -le $len ]; do
              end=\$(($pos + $step - 1))
              if [ $pos -lt 0 ]; then
                  start=1
              else
                  start=$pos
              fi
              if [ $end -gt $len ]; then
                  echo -n "--shard $chr:$start-$len "
                  pos=\$(($pos-$len))
                  break
              else
                  echo "--shard $chr:$start-$end"
                  pos=\$(($end + 1))
              fi
          done
      done
- class: InlineJavascriptRequirement

inputs:
- id: reference
  label: Reference
  doc: Reference fasta with associated fai index
  type: File
  secondaryFiles:
  - pattern: .fai
    required: true
  sbg:fileTypes: FA, FASTA
- id: size_of_chunks
  label: Size of each chunk
  doc: The size of each chunk (MB). We recommend using 100 MB bases as the shard size.
  type: int?
  default: 100
  inputBinding:
    position: 2
    valueFrom: $(inputs.size_of_chunks * 1000000)
    shellQuote: true

outputs:
- id: output
  type: string[]
  outputBinding:
    glob: shards.txt
    outputEval: "${\n    return self[0].contents.split(\"\\n\")\n}"
    loadContents: true

baseCommand:
- bash
- determine_shards.sh
arguments:
- prefix: ''
  position: 1
  valueFrom: "${\n    return inputs.reference.basename.concat(\".fai\")\n}"
  shellQuote: false
- prefix: ''
  position: 3
  valueFrom: '> shards.txt'
  shellQuote: false
