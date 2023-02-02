from report import Report
import click


@click.command()
@click.option(
    "--min",
    "-min",
    required=True,
    type=click.Path(exists=True, dir_okay=False),
    help="sta min report",
)
@click.option(
    "--max",
    "-max",
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

def main(min,max,output):
    result = ""
    tabs = "\t\t\t\t\t\t\t\t\t\t"
    removal_header = "removal\n\n"
    removal_header += f"Endpoint{tabs}  Slack\n"
    removal_header += "---------------------------------------------------\n"
    first_viol = 1
    report = Report(min)
    if report.removal_paths:
        for path in report.removal_paths:
            if path.slack < 0:
                if first_viol:
                    result += removal_header
                    first_viol = 0
                result += path.end_point 
                result += tabs
                result += str(path.slack)
                result += "\t(VIOLATED)\n"
        result+="\n"

    report = Report(max)
    if report.recovery_paths:
        recovery_header = "recovery\n\n"
        recovery_header += f"Endpoint{tabs}  Slack\n"
        recovery_header += "---------------------------------------------------\n"
        first_viol = 1
        for path in report.recovery_paths:
            if path.slack < 0:
                if first_viol:
                    result += recovery_header
                    first_viol = 0
                result += path.end_point 
                result += tabs
                result += str(path.slack)
                result += "\t(VIOLATED)\n"
        result+="\n"

    if result: 
        with open(output, "a") as stream:
            stream.write(result)

if __name__ == "__main__":
    main()
