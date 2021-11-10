async function fetchLink(arch: string, variant: string) {
  if (arch === "x64") arch = "x86_64";
  const list = await fetch("https://api.opengapps.org/list").then(e => e.json());
  return list.archs[arch].apis["11.0"].variants.find((e: { name: string }) => e.name === variant)!.zip;
}

if (await Deno.lstat("./#GAPPS/OpenGApps.zip").then(() => true).catch(() => false) && !Deno.args.includes("-f")) {
  console.log("./#GAPPS/OpenGApps.zip already present, skipping download.");
} else {
  const link = await fetchLink(Deno.args[0], Deno.args[1]);

  console.log("Downloading...");
  await Deno.writeFile("./#GAPPS/OpenGApps.zip", await fetch(link).then(e => e.arrayBuffer()).then(e => new Uint8Array(e)));
  console.log("Downloaded! Saved to ./#GAPPS/OpenGApps.zip.");
}
