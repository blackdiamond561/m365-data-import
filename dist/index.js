#!/usr/bin/env node
"use strict";
var chalk = require("chalk");
var clear = require("clear");
var figlet = require("figlet");
var path = require("path");
var program = require("commander");
clear();
console.log(chalk.white(figlet.textSync("m365di-cli", { horizontalLayout: "full" })));
program
    .version("0.0.1")
    .description("A command line interface for importing data into Microsoft365 locations")
    .option("-s, --source <source>", "The location of the source data")
    .option("-t, --target <target>", "The location of the target data")
    .parse(process.argv);
var options = program.opts();
console.log(options);
