import subprocess
import os
import json


class VerilogParser:
    def __init__(self, verilog_netlist, logger):
        self.verilog_netlist = verilog_netlist
        self.instances = {}
        self.logger = logger
        self.yosys_to_json()

    # self.instances[instance.name] = instance.module

    def yosys_to_json(self):
        yosys_env = os.environ.copy()
        script_path = os.path.dirname(os.path.abspath(__file__))
        yosys_env["YOSYS_VERILOG_IN"] = self.verilog_netlist
        yosys_env["YOSYS_JSON_OUT"] = "./tmp.json"
        self.logger.debug("running yosys ..")
        process = subprocess.run(
            f"yosys -c {script_path}/yosys/to-json.tcl".split(),
            env=yosys_env,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
        )
        if process.returncode:
            self.logger.error(process.stdout.decode("utf-8"))

        self.logger.debug("reading json ..")
        f = open("./tmp.json")
        data = json.load(f)
        f.close()
        os.remove("./tmp.json")
        module_name = os.path.basename(self.verilog_netlist)
        module_name = os.path.splitext(module_name)[0]
        self.logger.debug("parsing json ..")
        full_cells = data["modules"][module_name]["cells"]
        for cell in full_cells:
            self.instances[cell] = full_cells[cell]["type"]
