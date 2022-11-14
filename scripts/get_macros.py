from __future__ import absolute_import
from __future__ import print_function
from pathlib import Path
from verilog_parser import VerilogParser
from pdk_helpers import get_pdk_lefs_paths, get_macros
import click
import logging
import os
import sys


@click.command(
    help="""parses a verilog gatelevel netlist and
               prints the non scl instance names
               """
)
@click.option(
    "--input",
    "-i",
    required=True,
    type=click.Path(exists=True, dir_okay=False),
    help="input verilog netlist",
)
@click.option(
    "--pdk-root", required=True, type=click.Path(exists=True, file_okay=False)
)
@click.option("--pdk", required=True, type=str)
@click.option(
    "--output",
    "-o",
    required=True,
    type=str,
    help="output file in the format each line <instance_name> <instance_type>",
)
@click.option("--debug", is_flag=True)
def main(input, output, pdk_root, pdk, debug=False):
    """
    Parse a verilog netlist
    """
    logging.basicConfig(format="%(asctime)s | %(module)s | %(levelname)s | %(message)s")
    logger = logging.getLogger()
    if debug:
        logger.setLevel(logging.DEBUG)
    else:
        logger.setLevel(logging.INFO)

    output_path = Path(output)
    output_path.parents[0].mkdir(parents=True, exist_ok=True)

    pdk_macros = []
    logger.info("getting pdk macros..")
    lef_paths = get_pdk_lefs_paths(pdk_root, pdk)
    for lef in lef_paths:
        pdk_macros = pdk_macros + get_macros(lef)
    logger.debug(pdk_macros)

    logger.info("parsing netlist..")
    parsed = VerilogParser(input)
    logger.info("comparing macros against pdk macros..")
    # set SPEF_MAPPING_POSTFIX ".$::env(RCX_CORNER).spef"
    # set SPEF_MAPPING_PREFIX "$::env(CARAVEL_ROOT)/signoff/gpio_control_block/openlane-signoff/spef/"
    with open(output, "w") as f:
        for instance in parsed.instances:
            macro = parsed.instances[instance]
            if macro not in pdk_macros:
                logging.debug(f"{macro} not found in pdk_macros")
                f.write(f"{instance} {macro}\n")
    logger.info(f"wrote to {output}")


sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
if __name__ == "__main__":
    main()
