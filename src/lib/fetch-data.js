// https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Error#Custom_Error_Types
export const DataFetchError = function(message, xhr) {
	this.name = "DataFetchError";
	this.message = message || "Default Message";
	this.xhr = xhr;
	this.stack = new Error().stack;
};
DataFetchError.prototype = Object.create(Error.prototype);
DataFetchError.prototype.constructor = DataFetchError;

export const fetchData = url =>
	new Promise((resolve, reject) => {
		const xhr = new XMLHttpRequest();
		xhr.open("GET", url, true);
		xhr.responseType = "text"; // "json" is not supported in IE

		xhr.onload = function(e) {
			if (this.status == 200) {
				resolve(JSON.parse(this.responseText));
			} else {
				reject(new DataFetchError(this));
			}
		};
		xhr.onerror = function(e) {
			reject(new DataFetchError(this));
		};
		xhr.send();
	});

export default fetchData;
