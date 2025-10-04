import checkerboardWasmUrl from '/render.wasm?url';
const memory = new WebAssembly.Memory({ initial: 2, maximum: 2});

const canvas = document.querySelector("canvas");
const canvasContext = canvas.getContext('2d');

let importObject = {
    env: {
        memory: memory,
        consoleLog: (ptr, len) => {
            let str = new TextDecoder().decode(memory.buffer.slice(ptr, ptr + len));
            console.log(str);
        },
        renderLine: (line, ptr, len) => {
            let lineData = new Uint8ClampedArray(memory.buffer.slice(ptr, ptr + len));
            let imageData = new ImageData(lineData, canvas.width, 1);
            canvasContext.putImageData(imageData, 0, line);
        }
    }
};

const resultObject = await WebAssembly.instantiateStreaming(fetch(checkerboardWasmUrl), importObject);

resultObject.instance.exports.render(canvas.width, canvas.height);

