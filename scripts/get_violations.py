from pathlib import Path
from report import Report
import click
import logging
import sys

@click.command()
@click.option(
    "--input",
    "-i",
    required=True,
    type=click.Path(exists=True, dir_okay=False),
    help="sta report",
)
@click.option(
        "--append",
        "-a",
        is_flag=True
        )
def main(input, append):
    report = Report(input)


    result = ""
    violations = 0
    max_vio = 0
    for path in report.flipflop_flipflop_paths:
        if path.slack < 0:
            violations += 1
            max_vio = min(max_vio, path.slack)
    result += (f"flipflop-flipflop: {violations}/{len(report.flipflop_flipflop_paths)}")
    result += "\n"

    violations = 0
    for path in report.flipflop_output_paths:
        if path.slack < 0:
            violations += 1
    result += (f"flipflop-output: {violations}/{len(report.flipflop_output_paths)}")
    result += "\n"

    violations = 0
    for path in report.input_flipflop_paths:
        if path.slack < 0:
            violations += 1
    result += (f"input-flipflop: {violations}/{len(report.input_flipflop_paths)}")
    result += "\n"

    violations = 0
    for path in report.input_output_paths:
        if path.slack < 0:
            violations += 1
    result += (f"input-output: {violations}/{len(report.input_output_paths)}")
    result += "\n"

    violations = 0
    for path in report.unknown_paths:
        if path.slack < 0:
            violations += 1
    result += (f"unkown: {violations}/{len(report.unknown_paths)}")
    result += "\n"

    if append:
        with open(input, "a") as stream:
            stream.write(result)
    else:
        print(result)
    print(round(max_vio, 2))



if __name__ == "__main__":
    main()
