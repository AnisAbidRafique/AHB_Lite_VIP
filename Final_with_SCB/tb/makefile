# Define the compiler and simulator commands
COMPILER = xrun
COMPILE_FLAGS = -compile -elaborate
SIM_FLAGS = -R +UVM_TESTNAME=$(TEST_NAME)

# Define the files to be cleaned
FILES_TO_CLEAN = xrun.history *.log *.key qaLog.txt
DIRECTORIES_TO_CLEAN = waves.shm xcelium.d xcelium.shm cov_work
# Clean target: Remove all specified Celium-specific files
clean:
	@echo "Cleaning up Celium-specific files..."
	@rm -f $(FILES_TO_CLEAN)
	@rm -r $(DIRECTORIES_TO_CLEAN)
	@echo "Clean complete."

# Compile target: Compile the files using the -f file.f method
compile: file.f
	@echo "Compiling files..."
	$(COMPILER) $(COMPILE_FLAGS) -f file.f
	$(COMPILER) $(COMPILE_FLAGS) -f file.f
	@echo "Compilation complete."

# Test target: Run the simulation with the specified UVM_TESTNAME
# Usage: make test_name TEST_NAME=<test_name>
test_name: 
	@echo "Running test with UVM_TESTNAME=$(TEST_NAME)..."
	$(COMPILER) $(SIM_FLAGS)
	@echo "Test complete."

# Default target
all: clean compile

.PHONY: clean compile test_name all
