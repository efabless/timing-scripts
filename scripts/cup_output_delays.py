from report import Report
import click
import re
import textwrap


@click.command()
@click.option(
    "--input",
    "-i",
    required=True,
    type=click.Path(exists=True, dir_okay=False),
    help="sta report",
)
def main(input):
    report = Report(input)
    statements = []
    for path in report.paths:
        mprj_delay = 0
        data_arrival_time = 0
        net = ""
        if path.category == "unknown-reg":
            for path_line in path.path.split("\n"):
                if "user_project_wrapper" in path_line:
                    net = textwrap.dedent(path_line).split(" ")[0]
                    mprj_delay = float(
                        re.findall(
                            r"[+-]? *(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?", path_line
                        )[-1].strip()
                    )
                elif "data arrival time" in path_line:
                    data_arrival_time = float(
                        re.findall(
                            r"[+-]? *(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?", path_line
                        )[0].strip()
                    )
                    delta = round(data_arrival_time - mprj_delay, 2)
                    net = net.replace("mprj/", "")
                    net = "{" + net + "}"
                    statements.append(
                        f"set_output_delay -max {delta} -clock [get_clocks {{clk}}] -add_delay [get_ports {net}]"
                    )
                    break
        elif path.category == "unknown-output":
            for path_line in path.path.split("\n"):
                if "user_project_wrapper" in path_line:
                    net = textwrap.dedent(path_line).split(" ")[0]
                    mprj_delay = float(
                        re.findall(
                            r"[+-]? *(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?", path_line
                        )[-1].strip()
                    )
                elif "data arrival time" in path_line:
                    data_arrival_time = float(
                        re.findall(
                            r"[+-]? *(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?", path_line
                        )[0].strip()
                    )
                    delta = round(data_arrival_time - mprj_delay, 2)
                    net = net.replace("mprj/", "")
                    net = "{" + net + "}"
                    statements.append(
                        f"set_output_delay -max [expr $external_delay + {delta}] -clock [get_clocks {{clk}}] -add_delay [get_ports {net}]"
                    )
                    break


    for statement in statements:
        print(statement)


if __name__ == "__main__":
    main()
