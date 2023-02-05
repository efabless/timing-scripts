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
    type=click.Path(exists=True, dir_okay=False),
    help="output summary report",
)
@click.option(
    "--append", 
    "-a", 
    is_flag=True,
    help="append at the end of the given summary report"
)

def main(min, max, output, append):
    result = ""
    report = Report(min)
    if report.removal_paths:
        removal_header = f"removal\n\n"
        removal_header += f"{'Endpoint':50}{'Slack':>10}\n"
        removal_header += f"{'-':-<60}\n"
        first_viol = 1
        for path in report.removal_paths:
            if path.slack < 0:
                if first_viol:
                    result += removal_header
                    first_viol = 0
                result += f"{path.end_point:50}{path.slack:>10.2f} (VIOLATED)\n"
        result+="\n"

    report = Report(max)
    if report.recovery_paths:
        recovery_header = f"recovery\n\n"
        recovery_header += f"{'Endpoint':50}{'Slack':>10}\n"
        recovery_header += f"{'-':-<60}\n"
        first_viol = 1
        for path in report.recovery_paths:
            if path.slack < 0:
                if first_viol:
                    result += recovery_header
                    first_viol = 0
                result += f"{path.end_point:50}{path.slack:>10.2f} (VIOLATED)\n"
        result+="\n"

    if result:
        if append: 
            with open(output, "a") as stream:
                stream.write(result)
        else:
            with open(output,"w") as stream:
                stream.write(result)

if __name__ == "__main__":
    main()
