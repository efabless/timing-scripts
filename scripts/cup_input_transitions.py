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
        input_transition = 0
        net = ""
        path_lines = path.path.split("\n")
        for i in range(len(path_lines)):
            path_line = path_lines[i]
            if "user_project_wrapper" in path_line:
                net = textwrap.dedent(path_line).split(" ")[0]
                net = net.replace("mprj/", "")
                net = "{" + net + "}"
                input_transition_line = path_lines[i - 2]
                input_transition = float(re.findall(
                        r"[+-]? *(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?", input_transition_line
                    )[-3].strip())
                input_transition = round(input_transition, 2)
                statements.append(
                    f"set_input_transition -min {input_transition} [get_ports {net}]"
                )

                break

    for statement in statements:
        print(statement)


if __name__ == "__main__":
    main()
