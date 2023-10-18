from report import Report
import click


def filter_paths(paths, type):
    return [path for path in paths if path.path_type == type]

def filter_violating(paths):
    return [path for path in paths if path.slack < 0]

@click.command()
@click.option("--append", "-a", is_flag=True)
@click.option("--type", required=True, type=click.Choice(["min", "max"]))
@click.option("--category", type=click.Choice(["reg-reg", "reg-output", "input-reg", "input-output"]), default="reg-reg")
@click.argument(
    "input",
    type=click.Path(exists=True, dir_okay=False),
)
def main(input, append, type, category):
    report = Report(input)
    max_vio = 0
    paths_dict = {
        "reg-reg": report.reg_reg_paths,
        "reg-output": report.reg_output_paths,
        "input-reg": report.input_reg_paths,
        "input-output": report.input_output_paths,
    }
    result = f"{type}:\n"

    for sp_ep_pair, paths in paths_dict.items():
        filtered_paths = filter_paths(paths, type)
        violating_paths = filter_violating(filtered_paths)
        if violating_paths != [] and sp_ep_pair == category:
            max_vio = min(min(violating_paths, key=lambda x: x.slack).slack, max_vio)
        result += f"{sp_ep_pair}: {len(violating_paths)}/{len(filtered_paths)}\n"

    if append:
        with open(input, "a") as stream:
            stream.write(result)
    else:
        print(result)
    print(f"{max_vio:.2f}")


if __name__ == "__main__":
    main()
