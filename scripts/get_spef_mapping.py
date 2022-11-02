from __future__ import absolute_import
from __future__ import print_function
from pyverilog.vparser.parser import parse
from typing import List
import click
import logging
import os
import pyverilog
import sys
import sys


def get_pdk_lefs_paths(pdk_root: str, pdk: str) -> List[str]:
    lef_paths = []
    for root, dirs, files in os.walk(f"{pdk_root}/{pdk}"):
        for file in files:
            filename, file_extension = os.path.splitext(f"{file}")
            if file_extension == ".lef":
                lef_paths.append(f"{root}/{file}")
    return lef_paths


def get_macros(lef_file: str) -> List[str]:
    macros = []
    with open(lef_file) as f:
        for line in f.readlines():
            if "MACRO" in line:
                macro_name = line.split()[1]
                macros.append(macro_name)
    return macros


@click.command()
@click.option("--verilog-netlist", "-v", required=True, type=str)
@click.option("--project-root", "-p", required=True, type=str)
@click.option("--output", "-o", required=True, type=str)
@click.option("--debug", "-d", is_flag=True)
def main(verilog_netlist, project_root, output, debug=False):
    logging.basicConfig(format="%(asctime)s | %(module)s | %(levelname)s | %(message)s")
    logger = logging.getLogger()
    if debug:
        logger.setLevel(logging.DEBUG)
    else:
        logger.setLevel(logging.INFO)

    try:
        pdk_root = os.environ["PDK_ROOT"]
        pdk = os.environ["PDK"]
    except KeyError as err:
        logger.error(f"Undefined {err}")
        exit(1)

    logger.info(f"using project_root {project_root}")

    pdk_macros = []
    logger.info("getting pdk macros..")
    lef_paths = get_pdk_lefs_paths(pdk_root, pdk)
    for lef in lef_paths:
        pdk_macros = pdk_macros + get_macros(lef)
    logger.debug(pdk_macros)

    if not os.path.isfile(verilog_netlist):
        logger.error(f"netlist {verilog_netlist} not found")
        exit(1)

    files_list = [verilog_netlist]
    logger.info("parsing netlist..")
    ast, _ = parse(files_list)
    top_definition = None
    instances = {}

    for definition in ast.description.definitions:
        def_type = type(definition).__name__
        if def_type == "ModuleDef":
            top_definition = definition

    # Loop over each node under the top module definition
    for item in top_definition.items:
        item_type = type(item).__name__
        if item_type == "InstanceList":  # Module instances
            instance = item.instances[0]
            instances[instance.name] = instance.module

    logger.info("finding macros..")
#set SPEF_MAPPING_POSTFIX ".$::env(RCX_CORNER).spef"
#set SPEF_MAPPING_PREFIX "$::env(CARAVEL_ROOT)/signoff/gpio_control_block/openlane-signoff/spef/"
    postfix = ".$::env(RCX_CORNER).spef"
    with open(output, "w") as f:
        for instance in instances:
            macro = instances[instance]
            if not (macro in pdk_macros):
                logging.debug(f"{macro} not found in pdk_macros")
                prefix = f"{project_root}/signoff/{macro}/openlane-signoff/spef/"
                f.write(
                    f"set spef_mapping({instance}) {prefix}{macro}{postfix}\n"
                )
    logger.info(f"wrote to {output}")


sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
if __name__ == "__main__":
    main()
