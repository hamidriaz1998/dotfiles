function mpi
    if test (count $argv) -lt 1
        echo "Usage: mpi <filename> [num_processes]"
        return 1
    end

    set -l filename "$argv[1].c"
    set -l num_procs $argv[2]
    set -q num_procs; or set num_procs 4

    if not test -f "$filename"
        echo "Error: File '$filename' does not exist"
        return 1
    end

    mpicc -O2 "$filename" -o "$argv[1]"; or return 1

    mpirun -np $num_procs --oversubscribe ./"$argv[1]"
end
