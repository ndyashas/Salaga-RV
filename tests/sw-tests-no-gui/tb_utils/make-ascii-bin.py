import sys

if (__name__ == "__main__"):

    src_bin_data = ""
    with open(sys.argv[1], "rb") as bin_f:
        src_bin_data = bin_f.read()


    with open(sys.argv[2], "w") as dest_f:
        i = 0
        while(i < len(src_bin_data)):
            dest_f.write("{:02x}{:02x}{:02x}{:02x}\n".format(src_bin_data[i+3], src_bin_data[i+2], src_bin_data[i+1], src_bin_data[i]))
            i += 4
