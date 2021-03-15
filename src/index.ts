#!/usr/bin/env node

import { loadavg } from "os";
import yargs, { Argv } from "yargs";
const chalk = require("chalk");
const figlet = require("figlet");

console.log(
  chalk.white(figlet.textSync("m365di-cli", { horizontalLayout: "full" }))
);

const argv = yargs(process.argv.slice(2)).command(
  ["load", "import"],
  "Load data from the source location to the target location",
  {
    s: {
      type: "string",
      alias: "source",
      demandOption: true,
      description: "The source location",
    },
    t: {
      type: "string",
      alias: "target",
      demandOption: true,
      description: "The target location",
    },
  }
).argv;

const load = (source: string, target: string) => {
  console.log(source, target);
};

switch (argv._.join()) {
  case "import":
  case "load":
    load(argv["source"] as string, argv["target"] as string);
}
