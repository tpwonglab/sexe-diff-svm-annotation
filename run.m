addpath('utils/');

main();

function main
    clear main;
    clc;
    try
        choice = printInput("Choose the load data method:", ["Load a File", "Load a Folder"]);
        disp(choice);
    catch ME
        fprintf("Error caught: %s\n", ME.message);
    end
end

function choice = printInput(title, choices)
    choice = -1;
    while choice < 1 || choice > length(choices)
        disp(title);
        for i = 1:length(choices)
            fprintf("\t%d. %s\n", i, choices(i));
        end
        choice = input("Enter your choice as a number: ");
        if choice == -1
            error("User quits the program.");
        end
        fprintf("\n");
    end
end

