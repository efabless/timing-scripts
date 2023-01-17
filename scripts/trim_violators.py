#!/usr/bin/env python3

from report import Report
import click
import re
import textwrap


def trim(stream, endpoints):
    lines = []
    done = False
    violated = False
    last_pos = stream.tell()
    line = stream.readline()
    while line != '':
        for endpoint in endpoints:
            if endpoint in line:
                done = True

        if done:
            break
        if "VIOLATED" in line:
            if "mprj" in line:
                lines.append(line)
                violated = True
        else:
            lines.append(line)
        last_pos = stream.tell()
        line = stream.readline()

    stream.seek(last_pos)

    if not violated:
        lines = []

    return lines

@click.command()
@click.option(
    "--input",
    "-i",
    required=True,
    type=click.Path(exists=True, dir_okay=False),
    help="sta report",
)
@click.option(
    "--output",
    "-o",
    required=True,
    type=click.Path(dir_okay=False),
    help="sta report",
)
def main(input, output):
    lines = []
    keywords = ["max slew", "max capacitance", "min_delay/hold", "max_delay/setup"]
    append = True
    input_stream = open(input)
    line = input_stream.readline()
    while line != '':
        for keyword in keywords:
            if keyword in line:
                print(keyword)
                trimmed = trim(input_stream, keywords)
                if trimmed:
                    lines += line
                    lines += trimmed
                append = False
        if append:
            lines.append(line)
        line = input_stream.readline()
        append = True

    with open(output, "w") as output_stream:
        output_stream.writelines(lines)


if __name__ == "__main__":
    main()
