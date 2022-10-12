#!/usr/bin/env python3

import argparse
import textwrap


class Path:
    def __init__(self):
        self.start_point = ""
        self.end_point = ""
        self.path_group = ""
        self.path_type = ""
        self.path = ""
        self.computed_type = ""
        self.id = self.start_point + self.end_point


    def summarize(self):
        slack = ""
        for line in self.path.splitlines():
            if "slack" in line:
                slack = textwrap.dedent(line)
                break
        start_point = self.start_point.split()[0]
        end_point = self.end_point.split()[0]
        group = self.path_group
        type = self.path_type
        slack = slack.split()[0]
        return f"{start_point:20} {end_point:20} {group:10}{type:10}{slack:4}\n"


    def compute_path_type(self):
        start = ""
        end = ""
        if "input" in self.start_point:
            start = "input"
        else:
            start = "flipflop"
        if "output" in self.end_point:
            end = "output"
        else:
            end = "flipflop"

        self.computed_type = f"{start}-{end}"
        

    def get_id(self):
        self.id = self.start_point + self.end_point
        return self.id


    def __eq__(self, other):
        return self.get_id() == other.get_id()


    def __str__(self):
        return f"""
Startpoint: {self.start_point}
Endpoint: {self.end_point}
Path group: {self.path_group}
Path type: {self.path_type}
Path:
{self.path}
"""



class Report:
    def __init__(self, report_file):
        self.report_file = report_file
        self.paths = []
        self.build_db()

    def build_db(self):
        file = open(self.report_file)
        start_point = end_point = path_group = path_values = ""

        line = file.readline()
        while line != '':
            if "Startpoint" in line:
                x = file.tell()
                start_point = " ".join(line.split(' ')[1:])
                line2 = file.readline()
                if "Endpoint" not in line2:
                    start_point += line2
                else:
                    file.seek(x)
            elif "Endpoint" in line:
                x = file.tell()
                end_point = " ".join(line.split(' ')[1:])
                line2 = file.readline()
                if "Path Group" not in line2:
                    end_point += line2
                else:
                    file.seek(x)
            elif "Path Group" in line:
                path_group = line.split(' ')[2]
            elif "Path Type" in line:
                path_type = line.split(' ')[2]

                path_line = file.readline()
                while path_line != '':
                    if "Startpoint" in path_line:
                        path_object = Path()
                        path_object.start_point = start_point.rstrip()
                        path_object.end_point = end_point.rstrip()
                        path_object.path_group = path_group.rstrip()
                        path_object.path_type = path_type.rstrip()
                        path_object.path = path_values.rstrip()
                        path_object.compute_path_type()
                        self.paths.append(path_object)

                        start_point = " ".join(path_line.split(' ')[1:])
                        x = file.tell()
                        line2 = file.readline()
                        if "Endpoint" not in line2:
                            start_point += line2
                        else:
                            file.seek(x)

                        path_values = ""
                        break
                    else:
                        path_values += path_line
                    path_line = file.readline()
            line = file.readline()

        file.close()


parser = argparse.ArgumentParser(description="Summarize sta reports")
parser.add_argument("--report", required=True)
parser.add_argument("--output", required=True)

args = parser.parse_args()
report_file = args.report
output_file = args.output

report = Report(report_file)

output_files_stream = open(f"{output_file}", "w")

paths = report.paths
input_output_paths = []
input_flipflop_paths = []
flipflop_flipflop_paths = []
flipflop_output_paths = []

for path in paths:
    computed_path_type = path.computed_type
    if computed_path_type == "input-output":
        input_output_paths.append(path)
    elif computed_path_type == "input-flipflop":
        input_flipflop_paths.append(path)
    elif computed_path_type == "flipflop-flipflop":
        flipflop_flipflop_paths.append(path)
    elif computed_path_type == "flipflop-output":
        flipflop_output_paths.append(path)

output_files_stream.write(f"--------------input-flipflop_paths#{len(input_flipflop_paths)}-------------------\n")
for path in input_flipflop_paths:
    output_files_stream.write(path.summarize())
output_files_stream.write(f"--------------input-output_paths#{len(input_output_paths)}---------------------\n")
for path in input_output_paths:
    output_files_stream.write(path.summarize())
output_files_stream.write(f"--------------flipflop-flipflop_paths#{len(flipflop_flipflop_paths)}----------------\n")
for path in flipflop_flipflop_paths:
    output_files_stream.write(path.summarize())
output_files_stream.write(f"--------------flipflop-output_paths#{len(flipflop_output_paths)}------------------\n")
for path in flipflop_output_paths:
    output_files_stream.write(path.summarize())


