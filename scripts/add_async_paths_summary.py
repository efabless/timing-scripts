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
    report = Report(min)
    if report.removal_paths:
        result += "removal\n\n"
        result += f"Endpoint{tabs}  Slack\n"
        result += "---------------------------------------------------\n"
        for path in report.removal_paths:
            if path.slack < 0:
                result += path.end_point 
                result += tabs
                result += str(path.slack)
                result += "\t(VIOLATED)\n"
        result+="\n"

    report = Report(max)
    if report.recovery_paths:
        result += "recovery\n\n"
        result += f"Endpoint{tabs}  Slack\n"
        result += "---------------------------------------------------\n"
        for path in report.recovery_paths:
            if path.slack < 0:
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
