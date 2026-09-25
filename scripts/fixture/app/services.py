import os

class UserService:
    def __init__(self, repo):
        self.repo = repo

    async def get_user(self, uid):
        def _helper(x):
            return x
        if uid:
            return self.repo.find(uid)

def build_user_service():
    return UserService(None)
