from report import Report
import click


@click.command()
@click.option(
    "--min",
    required=True,
    type=click.Path(exists=True, dir_okay=False),
    help="sta min report",
)
@click.option(
    "--max",
    required=True,
    type=click.Path(exists=True, dir_okay=False),
    help="sta max report",
)
@click.option(
    "--output",
    "-o",
    required=True,
    type=click.Path(dir_okay=False),
    help="output summary report",
)
@click.option(
    "--append", "-a", is_flag=True, help="append at the end of the given summary report"
)
def main(min, max, output, append):
    min_result = ""
    report = Report(min)
    removal_header = f"\nremoval\n\n{'Endpoint':50}{'Slack':>10}\n{'-':-<60}\n"
    for path in report.removal_paths:
        if path.slack < 0:
            min_result += f"{path.end_point:50}{path.slack:>10.2f} (VIOLATED)\n"

    if min_result != "":
        min_result = removal_header + min_result

    max_result = ""
    report = Report(max)
    recovery_header = (
        f"\nrecovery\n\n{'Endpoint':50}{'Slack':>10}\n{'-':-<60}\n"
    )
    for path in report.recovery_paths:
        if path.slack < 0:
            max_result += f"{path.end_point:50}{path.slack:>10.2f} (VIOLATED)\n"

    if max_result != "":
        max_result = recovery_header + max_result

    result = min_result + max_result
    if result != "":
        write_mode = "a" if append else "w"
        with open(output, write_mode) as stream:
            stream.write(result)


if __name__ == "__main__":
    main()
