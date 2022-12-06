#!/usr/bin/env python3
from pathlib import Path
from subprocess import Popen, PIPE
import click
import grp
import logging
import os
import pwd
import shlex
import sys

from concurrent.futures import ProcessPoolExecutor as Pool


def copy_env():
    env = os.environ.copy()
    return env


def run_command(command, log, env, silent):
    logging.debug(f"Running command {command}")
    proc = Popen(
        command, universal_newlines=True, stdout=PIPE, encoding="utf-8", env=env
    )
    logging.info(f"Begin execution")
    logging.info(f"Logging to {log}")
    with open(log, "w") as log_stream:
        while proc.poll() is None:
            text = proc.stdout.readline()
            log_stream.write(text)
            if not silent:
                print(text, end="")
    logging.info(f"End execution")
    return proc.returncode


def rcx(
    pdk,
    pdk_root,
    def_file,
    output_file,
    process_corner,
    rc_corner,
    projects_paths,
    docker_image,
    log,
    silent=True,
):
    env_copy = copy_env()
    env_copy["PDK"] = pdk
    env_copy["PDK_ROOT"] = pdk_root
    env_copy["INPUT"] = def_file
    env_copy["OUTPUT"] = output_file
    env_copy["LIB_CORNER"] = process_corner
    env_copy["RCX_CORNER"] = rc_corner
    uid = pwd.getpwnam(env_copy["USER"])[2]
    gid = grp.getgrnam(env_copy["USER"])[2]
    script_path = Path().absolute()
    docker_mounts = f" -v {pdk_root}:{pdk_root}"
    for path in projects_paths:
        docker_mounts += f" -v {path}:{path}"

    logging.info(f"design: {def_file}")
    logging.info(f"corner: {rc_corner}")
    logging.info(f"spef: {output_file}")
    command = shlex.split(
        (
            f"docker run"
            f" --rm"
            f" -e INPUT={def_file}"
            f" -e OUTPUT={output_file}"
            f" -e PDK={pdk}"
            f" -e LIB_CORNER={process_corner}"
            f" -e RCX_CORNER={rc_corner}"
            f" -e PDK_REF_PATH={pdk_root}/{pdk}/libs.ref/"
            f" -e PDK_TECH_PATH={pdk_root}/{pdk}/libs.tech/"
            f" -e projects_paths=\"{' '.join(projects_paths)}\""
            f" -e TIMING_ROOT={script_path}"
            f" -v {pdk_root}:{pdk_root}"
            f" -v {script_path}:{script_path}"
            f" {docker_mounts}"
            f" -u {uid}:{gid}"
            f" {docker_image}"
            f" openroad -exit {script_path}/scripts/openroad/rcx.tcl"
        )
    )
    return run_command(command, env=env_copy, log=log, silent=silent)


def find_def(file, projects_paths):
    design_path = []
    for path in projects_paths:
        def_file = Path(path) / "def" / file
        if def_file.exists():
            design_path.append(def_file)

    return design_path


@click.command()
@click.option(
    "--projects-paths", multiple=True, type=click.Path(exists=True, file_okay=False),
)
@click.option(
    "--pdk-root", required=True, type=click.Path(exists=True, file_okay=False),
)
@click.option("--output-dir", type=click.Path(file_okay=False))
@click.option("--pdk", required=True)
@click.option(
    "--rc-corners",
    type=click.Choice(["nom", "min", "max"]),
    multiple=True,
    default=["nom"],
)
@click.option("--debug", default=False, is_flag=True)
@click.option("--threads", default=2)
@click.option(
    "--docker-image",
    default="efabless/openlane:d933bcd7df72d7c06a9086bc4c047bc9943deadf-amd64",
)
@click.argument("design")
def main(
    projects_paths,
    design,
    pdk,
    pdk_root,
    output_dir,
    rc_corners,
    docker_image,
    debug,
    threads,
):
    logging.basicConfig(
        level=logging.DEBUG if debug else logging.INFO,
        format="%(asctime)s | %(lineno)3s:%(funcName)-12s | %(levelname)6s | %(message)s"
        if debug
        else "%(levelname)6s | %(message)s",
        datefmt="%y-%m-%d(%H:%M)",
    )

    executor = Pool(max_workers=threads)

    pdk_path = Path(pdk_root) / pdk
    if not pdk_path.exists():
        logging.error(f"pdk({pdk} not found in {pdk_path})")

    logging.info(f"pdk: {pdk}")
    logging.info(f"pdk_root: {pdk_root}")

    design_paths = []
    if Path(design).exists():
        design_paths = [Path(design)]
    else:
        design_paths = find_def(f"{design}.def", projects_paths=projects_paths)
    if len(design_paths) > 1:
        logging.error(
            f"Found more than one def file for {design}. Please specify the def file"
        )

    valid_corners = ["nom", "min", "max"]
    if "all" in rc_corners:
        rc_corners = valid_corners

    logging.debug(rc_corners)
    futures = []
    for corner in rc_corners:
        output_file = Path(output_dir) / f"{design}-{corner}.spef"
        future = executor.submit(
            rcx,
            pdk=pdk,
            pdk_root=pdk_root,
            def_file=design_paths[0],
            output_file=output_file,
            rc_corner=corner,
            process_corner="t",
            projects_paths=projects_paths,
            docker_image=docker_image,
            log=f"./log-{corner}.log",
        )
        futures.append(future)
    sys.exit(max([future.result() for future in futures]))


if __name__ == "__main__":
    main()
