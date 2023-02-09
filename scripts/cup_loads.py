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
        load = 0
        net = ""
        for path_line in path.path.split("\n"):
            if "user_project_wrapper" in path_line:
                net = textwrap.dedent(path_line).split(" ")[0]
                mprj_delay = float(
                    re.findall(
                        r"[+-]? *(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?", path_line
                    )[-1].strip()
                )
                net = net.replace("mprj/", "")
                net = "{" + net + "}"
                statements.append(
                    f"set_load {load} [get_ports {net}]"
                )
                break
            elif "sky130_fd_sc_hd__buf_2" in path_line:
                load = float(
                    re.findall(
                        r"[+-]? *(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?", path_line
                    )[-4].strip()
                )
                load = round(load, 2)

    for statement in statements:
        print(statement)


if __name__ == "__main__":
    main()
