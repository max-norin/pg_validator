import * as fs from 'fs'

const getFiles = function (dir, recursive = true) {
  const result = []
  const files = fs.readdirSync(dir)
  for (const i in files) {
    const name = dir + '/' + files[i]
    if (fs.statSync(name).isDirectory()) {
      if (recursive) {
        result.concat(getFiles(name))
      }
    }
    else {
      result.push(name)
    }
  }
  return result
}

// fs.readFile('data.json', (e, data) => {
//   if (e) {
//     throw e
//   }
//   console.log(data)
// })

getFiles('./types')
