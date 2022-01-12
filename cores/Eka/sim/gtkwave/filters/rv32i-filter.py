#!/usr/bin/python3

import sys
import tempfile
import subprocess

def main():
    fh_in = sys.stdin
    fh_out = sys.stdout

    with tempfile.NamedTemporaryFile(mode='w') as obj_temp:
        with tempfile.NamedTemporaryFile(mode='w') as asm_temp:

            while True:
                l = fh_in.readline()
                if not l:
                    return 0

                if "x" in l:
                    fh_out.write(l)
                    fh_out.flush()
                    continue

                asm_temp.write(".word 0x%s\n" % l)
                asm_temp.flush()
                subprocess.run(["riscv64-unknown-linux-gnu-as", "-march=rv32i", "-o", obj_temp.name, asm_temp.name])
                result = subprocess.run(["riscv64-unknown-linux-gnu-objdump", "-d", obj_temp.name,
                                         "-M", "numeric", "-M", "no-aliases"], capture_output=True)
                lastline = result.stdout.splitlines()[-1]
                chunks = lastline.decode().split('\t')

                opcodes = " ".join(chunks[2:])

                fh_out.write("%s\n" % opcodes)
                fh_out.flush()


if __name__ == '__main__':
	sys.exit(main())