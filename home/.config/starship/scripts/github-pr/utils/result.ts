// Result型の定義
export type Result<T, E = Error> =
  | { value: T; error: undefined }
  | { value: undefined; error: E };

// 同期版のtry-catchをResult型で包む関数
export function tryCatch<T>(fn: () => T): Result<T> {
  try {
    const value = fn();
    return { value, error: undefined };
  } catch (error) {
    return { value: undefined, error: error as Error };
  }
}

// 非同期版のtry-catchをResult型で包む関数
export async function tryCatchAsync<T>(fn: () => Promise<T>): Promise<Result<T>> {
  try {
    const value = await fn();
    return { value, error: undefined };
  } catch (error) {
    return { value: undefined, error: error as Error };
  }
}