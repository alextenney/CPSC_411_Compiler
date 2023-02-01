import os

working_dir = "/home/ugb/alexandra.tenney/cpsc411_compiler/src/checker"

numbers = [
    1, 
    5, 
    #10, 
    11, 
    12, 
    #13, 
    14, 
    15, 
    #18, 
    22, 
    26, 
    29, 
    30, 
    31, 
    32, 
    #33, 
    34, 
    38
]


for i in range(len(numbers)):

    print("compiling " + str(numbers[i]))

    os.system(working_dir + "/main " + working_dir + "/final_tests/gen.t" + str(numbers[i]) + " > " + working_dir +  "/final_output/gen.t" + str(numbers[i]) + ".out")

    file_path = working_dir + '/mips_output/' + "gen.t" + str(numbers[i]) + ".mips"
    os.system("~aycock/411/bin/spim -file " + working_dir +  "/final_output/gen.t" + str(numbers[i]) + ".out > " + file_path)
