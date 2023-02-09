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
        clock_value = 0
        delay_value = 0
        net = ""
        for path_line in path.path.split("\n"):
            if "clock network delay" in path_line:
                clock_value = float(
                    re.findall(
                        r"[+-]? *(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?", path_line
                    )[0].strip()
                )
            elif "user_project_wrapper" in path_line:
                net = textwrap.dedent(path_line).split(" ")[0]
                delay_value = float(
                    re.findall(
                        r"[+-]? *(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?", path_line
                    )[-1].strip()
                )
                delta = round(delay_value - clock_value, 2)
                net = net.replace("mprj/", "")
                net = "{" + net + "}"
                statements.append(f"set_input_delay -min {delta} -clock [get_clocks {{clk}}] -add_delay [get_ports {net}]")
    for statement in statements:
        print(statement)


if __name__ == "__main__":
    main()
