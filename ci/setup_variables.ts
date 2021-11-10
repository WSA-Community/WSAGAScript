let variablesSource = await Deno.readTextFile("./VARIABLES.sh");

variablesSource = variablesSource.replace(/Architecture="(x64|arm64)"/, `Architecture="${Deno.args[0]}"`);

await Deno.writeTextFile("./VARIABLES.sh", variablesSource);
console.log("Successfully setup variables!");
