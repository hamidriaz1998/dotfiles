function kotlinc_run --description "Compile a Kotlin file to a runnable JAR and run it"
    # Check if a filename was provided as an argument
    if [ -z "$argv[1]" ]
        echo "Usage: kotlinc_run <filename.kt>"
        return 1
    end

    set kt_file $argv[1]
    set jar_file (basename $kt_file .kt)".jar"

    echo "Compiling $kt_file to $jar_file..."

    # Compile the Kotlin file into a self-contained JAR
    # -include-runtime adds the Kotlin stdlib to the JAR
    # -d specifies the output destination
    kotlinc $kt_file -include-runtime -d $jar_file

    # Check if compilation was successful
    if [ $status -ne 0 ]
        echo "Compilation failed."
        return 1
    end

    echo "Running the JAR file..."

    # Run the compiled JAR using the java command
    java -jar $jar_file

    # Optional: Clean up the generated JAR file after execution
    # rm $jar_file
end
