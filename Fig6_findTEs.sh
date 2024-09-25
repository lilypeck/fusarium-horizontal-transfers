##### first build the database then run repeatmodeler
#PBS -l walltime=48:00:00
#PBS -l select=1:ncpus=64:mem=244gb

cd $PBS_O_WORKDIR

module load anaconda3/personal
source activate repeatmodeler

singularity exec \
 --bind $PWD:$PWD \
 dfam-tetools-latest.sif BuildDatabase -name "ragtag.assemblies" -dir ragtag.assemblies

singularity exec \
 --bind $PWD:$PWD \
 dfam-tetools-latest.sif RepeatModeler \
 -database ragtag.assemblies \
 -pa 32 -LTRStruct


##### then run repeatmasker using customised TE library
#PBS -l walltime=24:00:00
#PBS -l select=1:ncpus=64:mem=124gb

cd $PBS_O_WORKDIR

module load anaconda3/personal
source activate repeatmodeler

 singularity exec \
 --bind $PWD:$PWD \
 dfam-tetools-latest.sif \
 RepeatMasker -lib ragtag.assemblies-families.manual.mimps.schmidt.fa \
 -pa 32 -s \
 -dir RM_out \
 -alignments \
 -gff -no_is \
 ragtag.assemblies/*.fasta