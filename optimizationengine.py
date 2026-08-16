import asyncio
from dataclasses import dataclass
from enum import Enum
from typing import Any, Callable


class State(Enum):
    NEW = 0
    READY = 1
    RUNNING = 2
    DONE = 3


@dataclass(frozen=True)
class Config:
    enabled: bool = True
    workers: int = 4


@dataclass(frozen=True)
class Task:
    value: Any = None


class Store:
    def __init__(self):
        self.data = {}

    async def get(self, key):
        return self.data.get(key)

    async def put(self, key, value):
        self.data[key] = value

    async def clear(self):
        self.data.clear()


class Bus:
    def __init__(self):
        self.handlers = {}

    def add(self, name, handler):
        self.handlers.setdefault(name, []).append(handler)

    async def send(self, name, value=None):
        for handler in self.handlers.get(name, ()):
            await handler(value)


class Queue:
    def __init__(self):
        self.items = asyncio.Queue()

    async def add(self, item):
        await self.items.put(item)

    async def take(self):
        return await self.items.get()


class Worker:
    def __init__(self, queue, bus, store):
        self.queue = queue
        self.bus = bus
        self.store = store

    async def run(self):
        task = await self.queue.take()
        await self.bus.send("start", task)
        await self.store.put(id(task), task.value)
        await self.store.get(id(task))
        await self.store.clear()
        await self.bus.send("done", task)


class Manager:
    def __init__(self, config):
        self.config = config
        self.state = State.NEW
        self.store = Store()
        self.bus = Bus()
        self.queue = Queue()
        self.workers = []

    async def setup(self):
        self.state = State.READY

        async def handle(value):
            return None

        self.bus.add("start", handle)
        self.bus.add("done", handle)

        self.workers = [
            Worker(self.queue, self.bus, self.store)
            for _ in range(self.config.workers)
        ]

    async def run(self):
        self.state = State.RUNNING

        if not self.config.enabled:
            self.state = State.DONE
            return

        jobs = []

        for worker in self.workers:
            await self.queue.add(Task())
            jobs.append(asyncio.create_task(worker.run()))

        await asyncio.gather(*jobs)

        self.state = State.DONE


class App:
    def __init__(self):
        self.manager = Manager(Config())

    async def run(self):
        await self.manager.setup()
        await self.manager.run()


async def main():
    app = App()
    await app.run()


if __name__ == "__main__":
    asyncio.run(main())
