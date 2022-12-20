#!/usr/bin/env python3

import argparse
from report import Report
from timing_path import TimingPath

parser = argparse.ArgumentParser(
    description="summarizes sta reports. tested on pt and opensta"
)
parser.add_argument("--input", "-i", required=True)
parser.add_argument("--output", "-o", required=True)

args = parser.parse_args()
report_file = args.input
output_file = args.output

report = Report(report_file)

output_files_stream = open(f"{output_file}", "w")

output_files_stream.write(
    f"--------------input-reg_paths#{len(report.input_reg_paths)}-------------------\n"
)
output_files_stream.write(TimingPath.get_header())
for path in report.input_reg_paths:
    output_files_stream.write(path.summarize())
output_files_stream.write(
    f"--------------input-output_paths#{len(report.input_output_paths)}---------------------\n"
)
output_files_stream.write(TimingPath.get_header())
for path in report.input_output_paths:
    output_files_stream.write(path.summarize())
output_files_stream.write(
    f"--------------reg-reg_paths#{len(report.reg_reg_paths)}----------------\n"
)
output_files_stream.write(TimingPath.get_header())
for path in report.reg_reg_paths:
    output_files_stream.write(path.summarize())
output_files_stream.write(
    f"--------------reg-output_paths#{len(report.reg_output_paths)}------------------\n"
)
output_files_stream.write(TimingPath.get_header())
for path in report.reg_output_paths:
    output_files_stream.write(path.summarize())
