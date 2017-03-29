import Vapor
import HTTP
import Fluent



struct RewardController: ResourceRepresentable {

    func index(request: Request) throws -> ResponseRepresentable {
        return try request.group().rewards.all().makeJSON()
    }

    func show(request: Request, reward: Reward) throws -> ResponseRepresentable {
        guard try reward.group.get()! == request.group() else {
            throw Abort.notFound
        }
        return reward
    }

    // FIXME: Needs to verify reward is being created in group user has access to
    func create(request: Request) throws -> ResponseRepresentable {
        let reward = try request.reward()
        try reward.save()
        return reward
    }

    func update(request: Request, reward: Reward) throws -> ResponseRepresentable {
        guard try reward.group.get()! == request.group() else {
            throw Abort.notFound
        }
        let new = try request.reward()
        let reward = reward
        reward.merge(updates: new)
        try reward.save()
        return reward
    }

    func delete(request: Request, reward: Reward) throws -> ResponseRepresentable {
        guard try reward.group.get()! == request.group() else {
            throw Abort.notFound
        }
        try reward.delete()
        return reward
    }

    func makeResource() -> Resource<Reward> {
        return Resource(
            index: index,
            store: create,
            show: show,
            modify: update,
            destroy: delete
        )
    }
}

extension RewardController {
    func claim(request: Request, reward: Reward) throws -> ResponseRepresentable {
        let user = try request.user()
        let group = try request.group()
        let score: Score

        let userReward = try UserReward(reward: reward, group: group, user: user)

        guard let userID    = user.id,
            let groupID   = group.id else {
                throw Abort.badRequest
        }

        if let scoreFound = try Score.query().filter("user_id", userID).filter("group_id", groupID).first() {
            score = scoreFound
        } else {
            score = try Score(group: group, user: user)
        }


        if score.points >= reward.cost {
            score.points -= reward.cost
            try userReward.save()
            try score.save()
            return "User score for group \(group.name) = \(score.points)!"
        } else {
            return "You don't have enough points to claim that reward"
        }
    }

    func markRecieved(request: Request, reward: Reward) throws -> ResponseRepresentable {
        return "Success"
    }

}

extension Request {
    func reward() throws -> Reward {
        guard let json = json else { throw Abort.badRequest }
        return try Reward(node: json)
    }
}
