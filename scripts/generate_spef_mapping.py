from __future__ import absolute_import
from __future__ import print_function
from pathlib import Path
from verilog_parser import VerilogParser
from pdk_helpers import get_macros, get_pdk_lefs_paths
import click
import logging
import os
import sys


@click.command(
    help="""parses a verilog gatelevel netlist and creates a
               spef mapping file for non pdk macros. the file is used
               along with the other scripts in the repo for proper parasitics annotation 
               during sta"""
)
@click.option(
    "--input",
    "-i",
    required=True,
    type=click.Path(exists=True, dir_okay=False),
    help="input verilog netlist",
)
@click.option(
    "--project-root",
    required=True,
    type=click.Path(exists=True, file_okay=False),
    help="path of the project that will be used in the output spef mapping file",
)
@click.option(
    "--output", "-o", required=True, type=str, help="spef mapping tcl output file"
)
@click.option(
    "--pdk-root", required=True, type=click.Path(exists=True, file_okay=False)
)
@click.option("--pdk", required=True, type=str)
@click.option("--debug", is_flag=True)
def main(input, project_root, output, pdk_root, pdk, debug=False):
    """
    Parse a verilog netlist
    """
    output_path = Path(output)
    output_path.parents[0].mkdir(parents=True, exist_ok=True)
    logging.basicConfig(format="%(asctime)s | %(module)s | %(levelname)s | %(message)s")
    logger = logging.getLogger()
    if debug:
        logger.setLevel(logging.DEBUG)
    else:
        logger.setLevel(logging.INFO)

    logger.info(f"using project_root {project_root}")

    pdk_macros = []
    logger.info("getting pdk macros..")
    lef_paths = get_pdk_lefs_paths(pdk_root, pdk)
    for lef in lef_paths:
        pdk_macros = pdk_macros + get_macros(lef)
    logger.debug(pdk_macros)

    logger.info("parsing netlist..")
    parsed = VerilogParser(input)
    logger.info("comparing macros against pdk macros..")
    postfix = ".$::env(RCX_CORNER).spef"
    with open(output, "w") as f:
        for instance in parsed.instances:
            macro = parsed.instances[instance]
            if not (macro in pdk_macros):
                logging.debug(f"{macro} not found in pdk_macros")
                spef_dir = "not-found"
                for macro_spef_file in Path(project_root).rglob(f"{macro}*.spef"):
                    spef_dir = macro_spef_file.parent
                    break
                
                macro_spef = f"{spef_dir}/{macro}{postfix}"
                f.write(f"set spef_mapping({instance}) \"{macro_spef}\"\n")
    logger.info(f"wrote to {output}")


sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
if __name__ == "__main__":
    main()
