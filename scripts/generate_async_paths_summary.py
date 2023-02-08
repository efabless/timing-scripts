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
    result = ""
    add_header = True
    report = Report(min)
    removal_header = f"\nremoval\n\n" f"{'Endpoint':50}{'Slack':>10}\n" f"{'-':-<60}\n"
    for path in report.removal_paths:
        if path.slack < 0:
            result += removal_header if add_header else ""
            add_header = False
            result += f"{path.end_point:50}{path.slack:>10.2f} (VIOLATED)\n"
    
    add_header = True
    report = Report(max)
    recovery_header = f"\nrecovery\n\n" f"{'Endpoint':50}{'Slack':>10}\n" f"{'-':-<60}\n"
    for path in report.recovery_paths:
        if path.slack < 0:
            result += recovery_header if add_header else ""
            add_header = False
            result += f"{path.end_point:50}{path.slack:>10.2f} (VIOLATED)\n"

    if result:
        write_mode = "a" if append else "w"
        with open(output, write_mode) as stream:
            stream.write(result)


if __name__ == "__main__":
    main()
